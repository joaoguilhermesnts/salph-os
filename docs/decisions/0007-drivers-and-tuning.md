# 0007 — Drivers e otimização

**Status:** adotado / adopted · 2026-11-27

Versões conferidas em packages.debian.org em 2026-11-27: kernel trixie 6.12.118,
kernel trixie-backports **7.3.4**, NVIDIA 550.163.01 (trixie e backports).

## Drivers (`config/package-lists/drivers.list.chroot`)
- **Vídeo Intel/AMD:** Mesa (OpenGL/Vulkan) + VA-API (`intel-media-va-driver`
  para Intel Gen8+, `i965-va-driver` para mais antigos, `mesa-va-drivers`
  para AMD). Firmware das GPUs já vem da lista de firmware.
- **GPU híbrida:** `switcheroo-control` habilita "Iniciar com a placa de vídeo
  dedicada" no GNOME.
- **Firmware de dispositivos:** `fwupd` (atualizações aparecem no GNOME Software).
- **Impressão:** CUPS + `ipp-usb` (impressoras sem driver, IPP Everywhere).
  `cups-browsed` desativado (adicionava filas da rede sozinho; teve falhas
  de segurança graves em 2024).
- **NVIDIA (decisão 0003):** fora da ISO. `salph-drivers` detecta a placa,
  avisa uma vez por notificação após a instalação e instala com
  `salph-drivers --install-nvidia`:
  - usa `nvidia-detect` para confirmar suporte;
  - instala do **mesmo repositório do kernel** — com kernel de backports,
    `-t trixie-backports`, senão o DKMS do 550 do trixie pode não compilar no 7.x;
  - com Secure Boot, registra a chave DKMS via `mokutil --import`.

## Kernel de backports — pin corrigido
O pin da Phase 1 listava `linux-image-6.*`, mas o backports já está no 7.x.
Agora: `linux-image-* linux-headers-* linux-kbuild-* linux-base` em 500.

## Atualizações
- **Segurança:** `unattended-upgrades` diário, com a configuração padrão do
  Debian (só `trixie-security`), sem reinício automático.
- **Kernel de backports:** a equipe de segurança do Debian não cobre o
  backports, e o unattended-upgrades não deve receber esse repositório inteiro.
  `salph-kernel-update.timer` roda diariamente e atualiza **só**
  `linux-image-amd64`/`linux-headers-amd64`.

## Desempenho
- **zram:** `systemd-zram-generator`, metade da RAM (máx. 8 GiB), zstd,
  prioridade acima de swap em disco. `vm.swappiness=180` e ajustes de
  watermark recomendados para zram (mesmo perfil de Fedora/Pop!_OS).
- **Serviços desativados:** `NetworkManager-wait-online` (atrasava o boot sem
  benefício no desktop), `cups-browsed` (ver acima), `thermald` no boot (é
  iniciado só em notebooks Intel).
- `fstrim.timer` ligado; journal limitado a 300 MB.

## Energia em notebooks
`salph-hwprofile.service` detecta notebook pelo tipo de chassi SMBIOS ou pela
presença de bateria do sistema e então: inicia `thermald` (Intel), ativa
economia de energia do áudio HDA e reduz a frequência de escrita do cache.
Os perfis (economia / equilibrado / desempenho) ficam no menu do GNOME via
`power-profiles-daemon`. TLP foi descartado: conflita com esse serviço e o
GNOME não o controla.

## Firewall
`ufw`, aplicado no primeiro boot (`salph-firstboot.service`): entrada
bloqueada, saída liberada, mDNS (5353/udp) liberado para descobrir impressoras.

## Riscos
- `--install-nvidia` com `-t trixie-backports` pode trazer também algumas
  bibliotecas do backports como dependência.
- Uma atualização de kernel pode sair antes do driver NVIDIA compatível no
  backports; nesse caso o sistema volta ao driver livre até a correção (o GRUB
  mantém o kernel anterior no menu "Opções avançadas").
- O firewall bloqueia o "Ponto de acesso Wi-Fi" do NetworkManager (DHCP para
  clientes). Liberar com `sudo ufw allow in on <interface>` se necessário.
- Firmware do trixie (20250410) é mais antigo que o kernel 7.3: hardware muito
  recente pode precisar de firmware do backports — avaliar com o hardware real.
- Ainda sem hardware de referência: falta a saída de `lspci -nn` e `lsusb`.
