# 0008 — Instalador Calamares e ISO

**Status:** adotado / adopted · 2026-11-27

Implementa a decisão 0004. Conferido em packages.debian.org (2026-11-27):
Calamares 3.3.14 (Qt6), sem configuração padrão no pacote; `calamares-settings-debian`
13.0.13 traz marca Debian e depende de QML do Qt5.

## Configuração própria (`config/includes.chroot/etc/calamares/`)
- **Telas:** boas-vindas → local → teclado → partição → usuários → resumo.
  O idioma do instalador segue a escolha no menu de boot (pt-BR / en-US) e pode
  ser trocado na tela de boas-vindas.
- **Sem acesso à internet:** GeoIP e links externos desativados.
- **Partição:** ext4 padrão; btrfs (subvolumes `@`, `@home`, `@cache`, `@log`,
  zstd) e xfs opcionais. Criptografia de disco completo com **LUKS1**, porque o
  GRUB 2.12 não abre LUKS2 com Argon2. Swap: nenhuma por padrão (zram).
- **Usuário:** grupo `sudo`, senha mínima de 8 caracteres, root sem senha
  (bloqueado), sem login automático.
- **GRUB:** grubcfg grava em `/etc/default/grub.d/`, sem tocar no conffile
  `/etc/default/grub` (evita perguntas no `apt full-upgrade`).

## Scripts do instalador (`/usr/lib/salph-os/installer/`)
- `prepare` (antes do initramfs): garante o kernel em `/boot`; remove
  live-boot, live-config, Calamares e os atalhos do live; ativa os dois
  idiomas; instala o metapacote **grub-efi-amd64** (UEFI) ou **grub-pc**
  (BIOS) a partir de `.deb` guardados no squashfs pelo hook `0500`.
- `finish` (depois do bootloader):
  - UEFI: `grub-install --force-extra-removable` cria `EFI/BOOT/BOOTX64.EFI`
    com o shim (o fallback do próprio Calamares copiaria só o GRUB e quebraria
    o Secure Boot); debconf `force_efi_extra_removable` mantém isso nas
    atualizações.
  - BIOS: grava o disco em `grub-pc/install_devices` (`/dev/disk/by-id/...`)
    para o `apt full-upgrade` não perguntar onde instalar o GRUB.

## Sessão live
- "Instalar o SALPH OS" é o primeiro ícone da dock (script `live-config`
  gerado no boot, não vai para a instalação). `salph-install` roda o Calamares
  como root na sessão Wayland (com XWayland como alternativa).

## Tela de boot
Plymouth, tema `salph` (módulo two-step): animação do tema spinner do Debian +
logo SALPH (`watermark.png`). Também exibe o pedido de senha do LUKS.

## Artefatos
`build.sh --sign KEYID` gera `.sha256`, assinaturas `.asc` da ISO e do
checksum, e exporta a chave pública. A assinatura usa o chaveiro do usuário
que chamou o `sudo`, não o do root.

## Riscos (validar na Phase 6)
- **Secure Boot com ID `salph`:** o GRUB assinado do Debian deve ler o
  `grub.cfg` do próprio diretório `EFI/salph`. Se o boot falhar com Secure Boot
  ligado, trocar `efiBootloaderId` para `debian` em `bootloader.conf` e
  `finish`.
- Chaves do Calamares (`efi:`, `prefer_grub_d`, `style`) conferidas pela
  documentação da série 3.3, sem teste real ainda.
- Kernel na mídia: se o squashfs não trouxer `/boot/vmlinuz-*`, o `prepare`
  copia de `/live`. O nome exato na mídia só será conhecido no primeiro build.
