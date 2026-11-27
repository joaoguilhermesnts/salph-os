#!/bin/bash
# SALPH OS — script principal de build / main build script
#
# Uso / Usage:
#   sudo ./build.sh [--version 0.1.0] [--snapshot 20261127T000000Z] [--sign KEYID] [--source] [--clean]
#
#   --source      também gera a ISO de código-fonte dos pacotes Debian (obrigação da GPL ao distribuir)
#                 also builds the source ISO of the Debian packages (GPL obligation when distributing)
#   --sign KEYID  assina ISO e .sha256 com a chave GPG KEYID do usuário que chamou o sudo
#                 signs the ISO and .sha256 with GPG key KEYID from the invoking user's keyring
#
# Requisitos: host Debian 13 (trixie) — físico, VM, WSL2 ou container privilegiado.
# Requirements: Debian 13 (trixie) host — bare metal, VM, WSL2 or privileged container.
set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")"

VERSION="dev"
SNAPSHOT=""
SIGN_KEY=""
SOURCE=false
CLEAN=0

while [ $# -gt 0 ]; do
	case "$1" in
		--version)  VERSION="$2"; shift 2 ;;
		--snapshot) SNAPSHOT="$2"; shift 2 ;;
		--sign)     SIGN_KEY="$2"; shift 2 ;;
		--source)   SOURCE=true; shift ;;
		--clean)    CLEAN=1; shift ;;
		-h|--help)  sed -n '2,15p' "$0"; exit 0 ;;
		*) echo "Opção desconhecida / unknown option: $1" >&2; exit 2 ;;
	esac
done

die() { echo "ERRO / ERROR: $*" >&2; exit 1; }

[ "$(id -u)" -eq 0 ] || die "execute como root (sudo) / run as root (sudo)"
command -v lb >/dev/null || die "live-build ausente: apt install live-build / live-build missing"
command -v msgfmt >/dev/null || die "gettext ausente: apt install gettext / gettext missing"
command -v python3 >/dev/null || die "python3 ausente: apt install python3 / python3 missing"
if [ -n "$SIGN_KEY" ]; then
	command -v gpg >/dev/null || die "gpg ausente: apt install gnupg / gnupg missing"
	SIGN_USER="${SUDO_USER:-root}"
	sudo -u "$SIGN_USER" gpg --list-secret-keys "$SIGN_KEY" >/dev/null 2>&1 \
		|| die "chave GPG $SIGN_KEY não encontrada para $SIGN_USER / GPG key not found"
fi

if ! grep -q 'VERSION_CODENAME=trixie' /etc/os-release 2>/dev/null; then
	echo "AVISO / WARNING: host não é Debian trixie; o build pode divergir." >&2
fi

# NTFS (/mnt/c no WSL) não suporta nós de dispositivo nem permissões POSIX.
case "$(pwd)" in
	/mnt/[a-z]/*) die "não faça build em /mnt/<drive> (NTFS). Copie o repo para ~/ no WSL." ;;
esac

export SALPH_VERSION="$VERSION"
export SALPH_SNAPSHOT="$SNAPSHOT"
export SALPH_SOURCE="$SOURCE"

# Reprodutibilidade: data fixa a partir do snapshot ou do último commit.
if [ -n "$SNAPSHOT" ]; then
	SOURCE_DATE_EPOCH="$(date -u -d "$(echo "$SNAPSHOT" | sed -E 's/(....)(..)(..)T(..)(..)(..)Z/\1-\2-\3 \4:\5:\6/')" +%s)"
elif git rev-parse --git-dir >/dev/null 2>&1 && git log -1 >/dev/null 2>&1; then
	SOURCE_DATE_EPOCH="$(git log -1 --format=%ct)"
else
	SOURCE_DATE_EPOCH="$(date -u +%s)"
fi
export SOURCE_DATE_EPOCH

if [ "$CLEAN" -eq 1 ]; then
	lb clean --purge
fi
lb clean
mkdir -p config/includes.chroot/usr/share/salph-os
echo "$VERSION" > config/includes.chroot/usr/share/salph-os/version
tools/l10n.sh stage
DOC=config/includes.chroot/usr/share/doc/salph-os
cp LICENSE CHANGELOG.md "$DOC/"
if ls LICENSES/*.txt >/dev/null 2>&1; then
	cp LICENSES/*.txt "$DOC/"
else
	echo "AVISO / WARNING: LICENSES/*.txt ausentes — obrigatórios antes de distribuir (ver LICENSES/README.md)" >&2
fi
python3 -I tools/gen-assets.py sounds
python3 -I tools/gen-assets.py png
lb config
lb build

ISO="salph-os-${VERSION}-amd64.hybrid.iso"
[ -f "$ISO" ] || die "ISO não gerada; veja build.log / ISO not produced; see build.log"

mkdir -p out
mv "$ISO" out/
[ -f "salph-os-${VERSION}-amd64.packages" ] && mv "salph-os-${VERSION}-amd64.packages" out/
for f in salph-os-"${VERSION}"-source*; do
	[ -e "$f" ] && mv "$f" out/
done
(cd out && sha256sum "$ISO" > "$ISO.sha256")

if [ -n "$SIGN_KEY" ]; then
	# Assina com o chaveiro do usuário, não do root.
	chown -R "$SIGN_USER": out
	for f in "out/$ISO.sha256" "out/$ISO"; do
		sudo -u "$SIGN_USER" gpg --batch --yes --armor --local-user "$SIGN_KEY" --detach-sign "$f"
	done
	sudo -u "$SIGN_USER" gpg --verify "out/$ISO.sha256.asc" "out/$ISO.sha256"
	sudo -u "$SIGN_USER" gpg --armor --export "$SIGN_KEY" > out/salph-os-signing-key.asc
fi

echo
echo "OK: out/$ISO"
echo "    out/$ISO.sha256"
if [ -n "$SIGN_KEY" ]; then
	echo "    out/$ISO.asc, out/$ISO.sha256.asc, out/salph-os-signing-key.asc"
else
	echo "Sem assinatura; use --sign KEYID / unsigned; use --sign KEYID"
fi
