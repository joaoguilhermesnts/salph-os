#!/bin/bash
# SALPH OS — verificação rápida dos critérios de aceitação num sistema instalado.
# SALPH OS — quick acceptance-criteria check on an installed system.
#
# Rode como o usuário criado no instalador, dentro da sessão GNOME:
# Run as the user created by the installer, inside the GNOME session:
#   bash smoke-test.sh            # só leitura / read-only (usa apt-get -s)
#   bash smoke-test.sh --upgrade  # também roda apt update && apt full-upgrade (pede sudo)
#
# Saída: PASS / FAIL / WARN por item e um resumo. Itens visuais ficam como
# MANUAL e estão no guia docs/testing.md.
# SPDX-License-Identifier: GPL-3.0-or-later
set -u

UPGRADE=0
[ "${1:-}" = "--upgrade" ] && UPGRADE=1

pass=0 fail=0 warn=0
ok()   { printf '\e[32mPASS\e[0m  %s\n' "$*"; pass=$((pass+1)); }
bad()  { printf '\e[31mFAIL\e[0m  %s\n' "$*"; fail=$((fail+1)); }
meh()  { printf '\e[33mWARN\e[0m  %s\n' "$*"; warn=$((warn+1)); }
check() { local d="$1"; shift; if "$@" >/dev/null 2>&1; then ok "$d"; else bad "$d"; fi; }
section() { printf '\n== %s ==\n' "$*"; }

section "Sistema / System"
. /etc/os-release
[ "${NAME:-}" = "SALPH OS" ] && ok "os-release: $PRETTY_NAME" || bad "os-release NAME=${NAME:-?}"
check "VERSION_CODENAME=trixie" test "${VERSION_CODENAME:-}" = trixie
check "Debian os-release preserved (dpkg-divert)" test -f /usr/lib/os-release.debian
check "not a live session" test ! -d /run/live/medium
for p in live-boot live-config calamares; do
	if dpkg-query -W -f='${Status}' "$p" 2>/dev/null | grep -q installed; then bad "live package still installed: $p"; else ok "removed: $p"; fi
done
grep -q . /usr/share/salph-os/build-info && ok "build-info: $(tr '\n' ' ' < /usr/share/salph-os/build-info)" || bad "build-info missing"

section "Boot"
if [ -d /sys/firmware/efi ]; then
	ok "firmware: UEFI"
	sb="$(mokutil --sb-state 2>/dev/null || true)"; echo "      $sb"
	check "EFI/salph present" test -d /boot/efi/EFI/salph
	check "removable fallback EFI/BOOT/BOOTX64.EFI" test -f /boot/efi/EFI/BOOT/BOOTX64.EFI
	check "grub-efi-amd64 installed" dpkg -s grub-efi-amd64
else
	ok "firmware: BIOS (legacy)"
	check "grub-pc installed" dpkg -s grub-pc
	dev="$(sudo -n debconf-show grub-pc 2>/dev/null | awk -F': ' '/install_devices:/ {print $2}')"
	if [ -n "$dev" ]; then ok "grub-pc install_devices: $dev"; else meh "grub-pc install_devices not readable (needs sudo) or empty"; fi
fi
check "Plymouth theme salph" sh -c 'plymouth-set-default-theme 2>/dev/null | grep -qx salph || grep -q salph /etc/plymouth/plymouthd.conf'
check "kernel from trixie-backports" sh -c "dpkg-query -W -f='\${Version}' linux-image-amd64 | grep -q bpo"

section "Idiomas / Languages"
check "locale pt_BR.UTF-8 generated" sh -c 'locale -a | grep -qi "^pt_BR.utf8$"'
check "locale en_US.UTF-8 generated" sh -c 'locale -a | grep -qi "^en_US.utf8$"'
echo "      system: $(localectl status 2>/dev/null | awk -F': ' '/System Locale/ {print $2}')"
check "salph-locale available" command -v salph-locale
check "translations installed" test -f /usr/share/locale/pt_BR/LC_MESSAGES/salph-os.mo

section "Interface"
if [ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
	ext="$(gsettings get org.gnome.shell enabled-extensions)"
	for e in salph-look@salph-os.org dash-to-dock@micxgx.gmail.com blur-my-shell@aunetx appindicatorsupport@rgcjonas.gmail.com; do
		case "$ext" in *"$e"*) ok "extension enabled: $e" ;; *) bad "extension not enabled: $e" ;; esac
	done
	if command -v gnome-extensions >/dev/null; then
		st="$(gnome-extensions info salph-look@salph-os.org 2>/dev/null | awk -F': ' '/State/ {print $2}')"
		[ "$st" = "ACTIVE" ] && ok "salph-look state ACTIVE" || bad "salph-look state: ${st:-unknown}"
	fi
	[ "$(gsettings get org.gnome.desktop.wm.preferences button-layout)" = "'close,minimize,maximize:'" ] \
		&& ok "window buttons on the left" || meh "button-layout changed: $(gsettings get org.gnome.desktop.wm.preferences button-layout)"
	gsettings get org.gnome.desktop.background picture-uri | grep -q salph && ok "SALPH wallpaper" || meh "wallpaper changed"
	echo "      session type: ${XDG_SESSION_TYPE:-?}"
else
	meh "no GNOME session bus: run inside the desktop session to check the interface"
fi

section "Hardware"
if command -v wpctl >/dev/null && wpctl status >/dev/null 2>&1; then
	sinks="$(wpctl status | sed -n '/Sinks:/,/Sources:/p' | grep -c '[0-9]\.')"
	[ "$sinks" -gt 0 ] && ok "audio: $sinks output(s) (PipeWire)" || bad "audio: no output devices"
else bad "audio: PipeWire not reachable"; fi
if nmcli -t -f TYPE device 2>/dev/null | grep -qx wifi; then
	ok "Wi-Fi device present ($(nmcli -t -f DEVICE,STATE device | grep -m1 -E '^wl' || true))"
else meh "no Wi-Fi device (expected in VMs)"; fi
if [ -d /sys/class/bluetooth ] && ls /sys/class/bluetooth | grep -q hci; then
	check "Bluetooth service active" systemctl is-active bluetooth
else meh "no Bluetooth adapter (expected in VMs)"; fi
for d in /sys/class/drm/card*/device/driver; do
	[ -e "$d" ] && echo "      GPU driver: $(basename "$(readlink -f "$d")") ($(cat "$(dirname "$d")/vendor" 2>/dev/null))"
done
command -v salph-drivers >/dev/null && salph-drivers --check | sed 's/^/      /'
echo "      chassis profile: $(cat /run/salph-os/chassis 2>/dev/null || echo '?')"

section "Otimização e segurança / Tuning and security"
check "zram swap active" sh -c 'swapon --noheadings --show=NAME | grep -q zram'
check "salph-hwprofile ran" systemctl is-active salph-hwprofile.service
check "first boot done" test -e /var/lib/salph-os/firstboot-done
check "ufw enabled" sh -c 'systemctl is-enabled ufw && grep -q "^ENABLED=yes" /etc/ufw/ufw.conf'
check "power-profiles-daemon active" systemctl is-active power-profiles-daemon
check "unattended-upgrades timer" systemctl is-enabled apt-daily-upgrade.timer
check "salph-kernel-update.timer enabled" systemctl is-enabled salph-kernel-update.timer
check "fstrim.timer enabled" systemctl is-enabled fstrim.timer
if systemctl is-enabled NetworkManager-wait-online.service >/dev/null 2>&1; then bad "NetworkManager-wait-online still enabled"; else ok "NetworkManager-wait-online disabled"; fi
check "Flathub remote" sh -c 'flatpak remotes --system | grep -q flathub'

section "APT"
bpo="$(dpkg-query -W -f='${Package} ${Version}\n' | awk '$2 ~ /bpo/ {print $1}' | grep -vE '^linux-(image|headers|kbuild)|^linux-base$|^nvidia|^firmware-' || true)"
[ -z "$bpo" ] && ok "only kernel packages from backports" || meh "non-kernel packages from backports: $(echo $bpo)"
if [ "$UPGRADE" -eq 1 ]; then
	if sudo apt update && sudo apt -y full-upgrade; then ok "apt update && apt full-upgrade"; else bad "apt update / full-upgrade failed"; fi
else
	if apt-get -s -o Debug::NoLocking=1 full-upgrade >/dev/null 2>&1; then ok "apt-get -s full-upgrade (simulation)"; else bad "apt-get -s full-upgrade"; fi
	echo "      run with --upgrade to perform the real upgrade"
fi

section "MANUAL (docs/testing.md)"
echo "  - visual: top bar, dock, rounded menus, light/dark wallpaper"
echo "  - keyboard shortcuts (Super, Alt+Tab, Super+arrows, Print)"
echo "  - switch pt-BR <-> en-US with salph-locale and log out/in"
echo "  - sound plays, Wi-Fi connects, Bluetooth pairs, video plays smoothly"

printf '\nResumo / Summary: %d PASS, %d FAIL, %d WARN\n' "$pass" "$fail" "$warn"
[ "$fail" -eq 0 ]
