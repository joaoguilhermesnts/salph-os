# Changelog

## Português (Brasil)

### 0.1.0 — não publicada
Primeira versão do SALPH OS, baseado em Debian 13.8 "trixie", kernel 7.3 (backports).

**Sistema**
- Debian 13 amd64 com atualizações de segurança; kernel do trixie-backports
  (série 7.x) com pinning restrito ao kernel.
- ISO híbrida UEFI + BIOS, inicia com Secure Boot ligado e via Ventoy.
- Build reproduzível com live-build e snapshot.debian.org; checksum SHA256,
  assinatura GPG e ISO de código-fonte opcionais.

**Idiomas**
- Português do Brasil padrão (ABNT2, America/Sao_Paulo) e inglês dos EUA,
  escolhidos no boot, no instalador ou no primeiro login.
- Troca sem reinstalar pelas Configurações ou com `salph-locale`.

**Interface**
- GNOME 48 com tema próprio sobre Adwaita: barra superior compacta, menus
  arredondados, botões de janela à esquerda, fonte Inter.
- Dock inferior (Dash to Dock) e desfoque da barra (Blur my Shell).
- Logo, wallpapers "Dunas" claro/escuro, sons de sistema e tela de boot originais.

**Aplicativos**
- Firefox ESR, LibreOffice (Writer, Calc, Impress), Programas (GNOME Software)
  com Flatpak e Flathub.

**Hardware e desempenho**
- Firmware para Intel, AMD, Wi-Fi, Bluetooth e áudio; Vulkan e aceleração de vídeo.
- Perfis de energia automáticos em notebooks; zram; serviços enxutos.
- `salph-drivers` para o driver NVIDIA opcional.
- Firewall (ufw) e atualizações de segurança automáticas.

**Instalador**
- Calamares com identidade SALPH: ext4, btrfs ou xfs, criptografia de disco
  completo, instalação lado a lado.

**Limitações conhecidas**
- Ainda não validada em hardware físico de referência.
- O driver NVIDIA exige registrar uma chave (MOK) quando o Secure Boot está ligado.
- O firewall bloqueia o ponto de acesso Wi-Fi até ser liberado manualmente.

## English (US)

### 0.1.0 — unreleased
First release of SALPH OS, based on Debian 13.8 "trixie", kernel 7.3 (backports).

**System**
- Debian 13 amd64 with security updates; trixie-backports kernel (7.x series)
  pinned so only the kernel comes from backports.
- Hybrid UEFI + BIOS ISO; boots with Secure Boot on and from Ventoy.
- Reproducible live-build build with snapshot.debian.org; SHA256 checksum,
  optional GPG signature and source ISO.

**Languages**
- Brazilian Portuguese by default (ABNT2, America/Sao_Paulo) and US English,
  selectable at boot, in the installer, or at first login.
- Switch without reinstalling via Settings or `salph-locale`.

**Interface**
- GNOME 48 with an own theme on top of Adwaita: compact top bar, rounded menus,
  window buttons on the left, Inter font.
- Bottom dock (Dash to Dock) and top bar blur (Blur my Shell).
- Original logo, "Dunes" light/dark wallpapers, system sounds and boot splash.

**Apps**
- Firefox ESR, LibreOffice (Writer, Calc, Impress), Software (GNOME Software)
  with Flatpak and Flathub.

**Hardware and performance**
- Firmware for Intel, AMD, Wi-Fi, Bluetooth and audio; Vulkan and video acceleration.
- Automatic laptop power profile; zram; trimmed services.
- `salph-drivers` for the optional NVIDIA driver.
- Firewall (ufw) and automatic security updates.

**Installer**
- SALPH-branded Calamares: ext4, btrfs or xfs, full-disk encryption, install alongside.

**Known limitations**
- Not yet validated on reference physical hardware.
- The NVIDIA driver needs a key (MOK) enrolled when Secure Boot is on.
- The firewall blocks the Wi-Fi hotspot until allowed manually.
