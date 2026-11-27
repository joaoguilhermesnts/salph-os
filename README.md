# SALPH OS

Distribuição Linux baseada em Debian 13 "trixie", com GNOME e linguagem visual
própria. *A Debian-based Linux distribution with GNOME and its own visual identity.*

> SALPH OS não é afiliado ao Projeto Debian. *Not affiliated with the Debian Project.*

## Estado / Status
Versão 0.1.0 com as 6 fases escritas (base, idiomas, tema, drivers, instalador,
testes e documentação). **Ainda não compilada nem validada:** o próximo passo
é o primeiro build e a matriz de testes em `docs/testing.md`.

## Documentação / Documentation
| | |
|---|---|
| [docs/install.md](docs/install.md) | instalação (uso pessoal) e distribuição |
| [docs/testing.md](docs/testing.md) | guia de testes em VM e hardware físico |
| [docs/ventoy-secure-boot.md](docs/ventoy-secure-boot.md) | pendrive Ventoy e Secure Boot |
| [docs/i18n.md](docs/i18n.md) | idiomas e tradução |
| [docs/packages-and-tweaks.md](docs/packages-and-tweaks.md) | pacotes e ajustes aplicados |
| [docs/build-windows.md](docs/build-windows.md) | build no Windows via WSL2 |
| [docs/decisions/](docs/decisions/) | decisões técnicas (0001–0008) |
| [CHANGELOG.md](CHANGELOG.md) | mudanças por versão (pt-BR / en-US) |
| [THIRD_PARTY.md](THIRD_PARTY.md) | componentes de terceiros e licenças |

## Build
Requer host Debian 13 com `live-build` e `gettext`. Idiomas: [docs/i18n.md](docs/i18n.md). No Windows, veja [docs/build-windows.md](docs/build-windows.md).
```bash
sudo ./build.sh --version 0.1.0-alpha1
# reproduzível / reproducible:
sudo ./build.sh --version 0.1.0-alpha1 --snapshot 20261127T000000Z
# para distribuir / release: assinado + código-fonte
sudo ./build.sh --version 0.1.0 --snapshot <AAAAMMDDTHHMMSSZ> --sign <KEYID> --source
```
Saída: `out/salph-os-<versão>-amd64.hybrid.iso`, `.sha256`, lista de pacotes e, com `--sign`, assinaturas `.asc`.
Pendrive Ventoy e Secure Boot: [docs/ventoy-secure-boot.md](docs/ventoy-secure-boot.md).

## Estrutura / Layout
```
auto/config              opções do live-build (distribuição, boot, espelhos)
config/package-lists/    pacotes por grupo (base, firmware, desktop, l10n, apps, drivers, installer)
config/hooks/live/       scripts executados dentro do chroot
config/includes.chroot/  arquivos copiados para o sistema
docs/decisions/          decisões técnicas e o motivo de cada uma
src/                     scripts próprios instalados em /usr/bin (gettext)
po/                      traduções pt_BR / en_US
tools/l10n.sh            extrair, atualizar, validar e compilar traduções
tools/gen-assets.py      gera logo, wallpapers e sons originais
tests/qemu-run.sh        VM QEMU em UEFI, UEFI + Secure Boot ou BIOS
tests/smoke-test.sh      verificação dos critérios de aceitação no sistema instalado
src/salph-drivers        detecta GPU NVIDIA e instala o driver opcional
src/salph-install        abre o instalador na sessão live
config/includes.chroot/etc/calamares/  instalador (módulos, branding, slides)
docs/ventoy-secure-boot.md  pendrive Ventoy e Secure Boot
THIRD_PARTY.md           licenças de componentes de terceiros
```

## Licença / License
Código e configurações: GPL-3.0-or-later. Arte (logo, wallpapers, sons):
CC-BY-SA-4.0. O nome e o logo SALPH OS identificam o projeto; versões
modificadas devem usar outro nome e logo. Detalhes em [LICENSE](LICENSE).
