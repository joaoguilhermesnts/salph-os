#!/bin/sh
# Ferramentas de tradução / translation tooling (gettext)
#
#   tools/l10n.sh pot     extrai strings de src/ para po/salph-os.pot
#   tools/l10n.sh update  atualiza po/*.po a partir do .pot (msgmerge)
#   tools/l10n.sh check   valida po/*.po (msgfmt --check) e mostra pendências
#   tools/l10n.sh stage   compila .mo e copia scripts para config/includes.chroot
set -eu

cd "$(dirname "$0")/.."
DOMAIN=salph-os
LANGS="pt_BR en_US"
STAGE=config/includes.chroot

sources() { find src -type f | sort; }

case "${1:-}" in
	pot)
		xgettext --language=Shell --from-code=UTF-8 \
			--package-name="SALPH OS" --msgid-bugs-address="" \
			--add-comments=TRANSLATORS --sort-by-file \
			-o "po/$DOMAIN.pot" $(sources)
		echo "po/$DOMAIN.pot"
		;;
	update)
		for l in $LANGS; do
			msgmerge --quiet --update --backup=none "po/$l.po" "po/$DOMAIN.pot"
		done
		;;
	check)
		for l in $LANGS; do
			printf '%s: ' "$l"
			msgfmt --check --statistics -o /dev/null "po/$l.po"
		done
		;;
	stage)
		for l in $LANGS; do
			d="$STAGE/usr/share/locale/$l/LC_MESSAGES"
			mkdir -p "$d"
			msgfmt --check -o "$d/$DOMAIN.mo" "po/$l.po"
		done
		mkdir -p "$STAGE/usr/bin"
		for f in $(sources); do
			install -m 0755 "$f" "$STAGE/usr/bin/$(basename "$f")"
		done
		echo "staged translations and scripts into $STAGE"
		;;
	*)
		sed -n '2,8p' "$0"; exit 2 ;;
esac
