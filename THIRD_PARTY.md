# Componentes de terceiros e licenças / Third-party components and licenses

Lista completa de pacotes: gerada a cada build em `out/*.packages`; licenças
individuais em `/usr/share/doc/<pacote>/copyright` no sistema.

| Componente | Origem | Licença | Observação |
|---|---|---|---|
| Debian trixie (base) | debian.org | várias (DFSG) | "SALPH OS, baseado em Debian" — sem sugerir endosso |
| live-build | Debian main | GPL-3.0+ | ferramenta de build, não vai na ISO |
| firmware-* (non-free-firmware) | Debian | proprietária, redistribuível | listado em `config/package-lists/firmware.list.chroot` |
| intel-microcode / amd64-microcode | Debian non-free-firmware | proprietária, redistribuível | |
| GNOME, gnome-initial-setup | Debian main | GPL-2.0+ / LGPL | |
| hunspell-pt-br, hunspell-en-us | Debian main | LGPL-3 / MPL-1.1 e outras | ver copyright de cada pacote |
| manpages-pt-br | Debian main | GPL e licenças das man pages | |
| Scripts SALPH OS (`src/`, `tools/`, `config/`) | este repositório | GPL-3.0-or-later | |
| Tema GTK, ícones e cursor Adwaita | Debian main | LGPL-3 / CC-BY-SA-3.0 | decisão 0006 |
| Dash to Dock, Blur my Shell, AppIndicator | Debian main | GPL-2.0+ / GPL-3.0 | extensões do GNOME Shell |
| Inter, JetBrains Mono, Cantarell, Noto Color Emoji | Debian main | SIL OFL 1.1 | |
| Firefox ESR + l10n pt-BR | Debian main | MPL-2.0 | marca Mozilla: binário Debian sem modificações |
| LibreOffice + l10n/ajuda | Debian main | MPL-2.0 | |
| GNOME Software, Flatpak | Debian main | GPL-2.0+ / LGPL-2.1+ | |
| Flathub (remoto) | flathub.org | licença de cada app | fonte de terceiros, fora do Debian |
| Extensão salph-look, scripts | este repositório | GPL-3.0-or-later | |
| Logo, wallpapers, sons SALPH | este repositório (`tools/gen-assets.py`) | CC-BY-SA-4.0 | originais; nome e logo são identidade do projeto |
| Calamares 3.3 (Qt6) | Debian main | GPL-3.0+ | configuração e branding próprios (decisões 0004, 0008) |
| GRUB 2.12, shim-signed, efibootmgr, os-prober | Debian main | GPL-3.0+ / BSD-2-Clause (shim) | shim e GRUB assinados pelo Debian (Secure Boot) |
| Plymouth + animação do tema spinner | Debian main | GPL-2.0+ | tema salph usa as imagens do spinner + logo SALPH |
| Configuração Calamares, scripts do instalador, show.qml | este repositório | GPL-3.0-or-later | |
| Driver NVIDIA | Debian non-free | proprietária | fora da ISO; `salph-drivers --install-nvidia` (decisões 0003, 0007) |
| Mesa, VA-API, fwupd, CUPS, ipp-usb, power-profiles-daemon, thermald, ufw, unattended-upgrades, systemd-zram-generator | Debian main | MIT / GPL-2.0+ / LGPL / Apache-2.0 (ver copyright de cada pacote) | decisão 0007 |

## Política de marcas
- Não usar o logo Debian (swirl) na identidade; citar "baseado em Debian" em texto.
- Não usar "macOS", "Apple" nem qualquer asset da Apple; o design é apenas inspiração.
