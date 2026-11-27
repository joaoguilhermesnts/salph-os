# Pacotes e ajustes / Packages and tweaks — SALPH OS 0.1

A lista exata de pacotes (com versões) de cada ISO é gerada no build em
`out/salph-os-<v>-amd64.packages`. *The exact versioned package list of each
ISO is produced by the build in `out/salph-os-<v>-amd64.packages`.*

## Pacotes escolhidos / Selected packages (`config/package-lists/`)

| Lista / List | Pacotes / Packages | Motivo / Why |
|---|---|---|
| base | live-boot, live-config(-systemd), systemd-sysv, linux-image-amd64, sudo, locales, keyboard-configuration, console-setup, tzdata, ca-certificates, curl, nano, less, bash-completion, network-manager | Sistema base e sessão live |
| firmware | firmware-linux-free, -misc-nonfree, -amd-graphics, -intel-graphics, -intel-sound, -iwlwifi, -realtek, -atheros, -brcm80211, -libertas, -sof-signed, intel-microcode, amd64-microcode, bluez, bluez-firmware | Vídeo, Wi-Fi, áudio e Bluetooth na maioria dos PCs (non-free-firmware) |
| desktop | gnome-core, gdm3, dconf-cli, pipewire-audio, wireplumber, librsvg2-common, extensões dashtodock / blur-my-shell / appindicator / prefs, fonts-inter, fonts-jetbrains-mono, fonts-cantarell, fonts-noto-color-emoji, sound-theme-freedesktop | GNOME 48 + dock + fontes |
| l10n | locales, gettext-base, hunspell-pt-br, hunspell-en-us, manpages-pt-br, gnome-initial-setup, xdg-user-dirs-gtk | pt-BR e en-US |
| apps | firefox-esr (+l10n pt-br), libreoffice writer/calc/impress/gnome (+l10n e ajuda), gnome-software (+flatpak), flatpak | Apps padrão (decisão 0006) |
| drivers | mesa-vulkan-drivers, mesa-va-drivers, intel-media-va-driver, i965-va-driver, vainfo, switcheroo-control, fwupd, pciutils, usbutils, mokutil, libnotify-bin, cups, ipp-usb, power-profiles-daemon, thermald, iio-sensor-proxy, systemd-zram-generator, unattended-upgrades, ufw | Drivers, energia, segurança (decisão 0007) |
| installer | calamares, qt6-wayland, x11-xserver-utils, rsync, squashfs-tools, dosfstools, btrfs-progs, xfsprogs, cryptsetup(-initramfs), grub2-common, grub-common, grub-pc-bin, grub-efi-amd64-bin, grub-efi-amd64-signed, shim-signed, efibootmgr, os-prober, plymouth, plymouth-themes | Instalador e boot (decisão 0008) |

**Repositórios / Repositories:** trixie, trixie-security, trixie-updates (main,
contrib, non-free, non-free-firmware); trixie-backports só para o kernel
(pin 500; resto 100). Flathub (remoto Flatpak).

## Ajustes aplicados / Applied tweaks

| Área / Area | Ajuste / Tweak | Onde / Where |
|---|---|---|
| Identidade | `os-release` SALPH OS (`ID=salph`, `ID_LIKE=debian`), original desviado | hook 0300 |
| Idioma | locales pt_BR/en_US, padrão pt_BR, ABNT2, America/Sao_Paulo | hook 0100 |
| Boot | entrada "English (US)" no GRUB e ISOLINUX; Plymouth tema `salph` | hooks 0200, 0500 |
| Interface | botões à esquerda, Inter/JetBrains Mono, acento azul, wallpaper Dunas, sons SALPH, dock inferior com autohide, desfoque da barra | `/etc/dconf/db/local.d/00-salph-defaults` |
| Interface | extensão `salph-look` (CSS da barra, menus e dock) | `/usr/share/gnome-shell/extensions/` |
| Login | logo SALPH no GDM | `/etc/dconf/db/gdm.d/` |
| Memória | zram (50% RAM, máx. 8 GiB, zstd), swappiness 180, page-cluster 0 | `zram-generator.conf`, `sysctl.d/90-salph-zram.conf` |
| Serviços | desativados: NetworkManager-wait-online, cups-browsed, thermald (no boot) | hook 0400 |
| Serviços | ativados: fstrim.timer, salph-hwprofile, salph-firstboot, salph-kernel-update.timer | hook 0400 |
| Energia | notebook detectado: thermald (Intel), economia de energia do áudio, writeback 15 s | `salph-hwprofile` |
| Logs | journal máx. 300 MB | `journald.conf.d/50-salph.conf` |
| Atualizações | unattended-upgrades diário (segurança); kernel de backports diário | `apt.conf.d/21salph-auto-upgrades`, `salph-kernel-update` |
| Firewall | ufw: entrada bloqueada, saída liberada, mDNS liberado | `salph-firstboot` |
| Instalador | Calamares próprio; GRUB por firmware; fallback UEFI com shim; debconf do grub-pc | `/etc/calamares`, `/usr/lib/salph-os/installer/` |
| Drivers | NVIDIA opcional via `salph-drivers`, aviso único após instalar | `/usr/bin/salph-drivers`, autostart |

## Comandos próprios / Own commands
- `salph-locale <pt-BR|en-US> [--keyboard br|us] [--user-only]`
- `salph-drivers [--check|--install-nvidia|--notify]`
- `salph-install` (só na sessão live / live session only)
