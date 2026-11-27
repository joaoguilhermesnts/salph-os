# 0001 — Sistema de build: live-build

**Status:** adotado / adopted · 2026-11-27

## Decisão
Usar `live-build` (pacote Debian oficial) com a configuração em `auto/config`
e `config/`, tudo versionado no repositório.

## Motivo
- É a ferramenta usada pelas imagens live oficiais do Debian, inclusive as que
  trazem Calamares; gera ISO híbrida (UEFI + BIOS) nativamente.
- `debian-cd` é voltado a mídias do debian-installer e exige um espelho local
  completo — mais pesado e sem ganho para uma imagem live com instalador gráfico.
- Configuração declarativa (listas de pacotes, includes, hooks) é fácil de revisar.

## Reprodutibilidade
- `--snapshot AAAAMMDDTHHMMSSZ` faz o build usar `snapshot.debian.org`, congelando
  as versões dos pacotes. A ISO instalada continua apontando para `deb.debian.org`.
- `SOURCE_DATE_EPOCH` é derivado do snapshot ou do último commit.
- A point release real (ex.: 13.8) é registrada em `/usr/share/salph-os/build-info`
  durante o build — confirmar esse valor em debian.org/releases antes de publicar.

## Boot
- `--bootloaders grub-efi,syslinux`: GRUB para UEFI, ISOLINUX para BIOS legado.
- `--uefi-secure-boot enable`: usa `shim-signed` + `grub-efi-amd64-signed` do
  Debian (assinados pela Microsoft), então a ISO inicia com Secure Boot ligado.
  Via Ventoy com Secure Boot, é preciso registrar a chave do Ventoy (MOK) uma vez
  — será documentado na Phase 5.

## Host de build
Debian 13. Em Windows, usar WSL2 com Debian (ver `docs/build-windows.md`),
sempre dentro do sistema de arquivos Linux (`~/`), nunca em `/mnt/c`.
