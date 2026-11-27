# Resultados de teste / Test results — SALPH OS <versão / version>

- ISO: `salph-os-<v>-amd64.hybrid.iso`
- SHA256: `<hash>`
- Debian point release (`/usr/share/salph-os/build-info`): `13.x`
- Kernel: `<uname -r>`
- Testado por / Tested by: `<nome>` · Data / Date: `AAAA-MM-DD`

| # | Ambiente / Environment | Firmware | Idioma / Language | Boot ISO | Instalação / Install | 1º boot | smoke-test (FAIL/WARN) | Manual | Observações / Notes |
|---|---|---|---|---|---|---|---|---|---|
| V1 | QEMU | UEFI | pt-BR | | | | | | |
| V1 | QEMU | UEFI | en-US | | | | | | |
| V2 | QEMU | UEFI + SB | pt-BR | | | | | | |
| V2 | QEMU | UEFI + SB | en-US | | | | | | |
| V3 | QEMU | BIOS | pt-BR | | | | | | |
| V3 | QEMU | BIOS | en-US | | | | | | |
| V4 | VirtualBox | UEFI | | | | | | | |
| V4 | VirtualBox | BIOS | | | | | | | |
| V5 | VMware | UEFI | | | | | | | |
| V5 | VMware | BIOS | | | | | | | |
| F1 | `<modelo>` Ventoy | UEFI + SB | | | | | | | |
| F2 | `<modelo>` Ventoy | Legado | | | | | | | |

Variações / Variants: criptografia / encryption ☐ · btrfs ☐ · `apt full-upgrade` ☐ · troca de idioma / language switch ☐

Hardware F1/F2 — `lspci -nn` / `lsusb`:
```
```
