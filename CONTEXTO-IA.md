# SALPH OS — Contexto para continuar o projeto (handoff para IA)

> Documento gerado em 2026-11-27 para continuar o trabalho em outro computador
> ou com outra IA. Resume o pedido original, as decisões tomadas com o usuário,
> o que foi implementado, o estado atual e os próximos passos.
>
> Leia junto com: `README.md`, `docs/decisions/` (0001–0008), `CHANGELOG.md`.

---

## 1. O projeto em uma frase

**SALPH OS** é uma distribuição Linux **baseada em Debian 13 "trixie" (amd64)**,
com **GNOME** e visual **inspirado** no macOS. Tem barra superior, dock inferior,
cantos arredondados e botões de janela à esquerda, mas **identidade 100%
própria**: nome, logo, wallpapers e sons são originais, sem nenhum asset da
Apple e sem usar "macOS" como marca. Uso pessoal e distribuição para outras pessoas.

- **Repositório:** https://github.com/joaoguilhermesnts/salph-os (**privado**), branch `main`
- **Pasta local original:** `C:\Users\senai.PC03LAB2537\Downloads\MW OS` (PC Windows do SENAI, **sem admin e sem Linux**)
- **Idioma de trabalho:** o usuário escreve em **pt-BR**. Documentação bilíngue (pt-BR + en-US).

## 2. Requisitos originais (resumo da especificação do usuário)

- Base Debian 13 stable (point release confirmada no build: **13.8**). Nada de testing/unstable.
- `trixie-backports` só de forma seletiva e com pinning explícito.
- Hardware: amd64 genérico; drivers livres Intel/AMD, Wi-Fi, Bluetooth, áudio,
  `non-free-firmware`. NVIDIA proprietário **opcional**. Perfis de energia
  automáticos em notebooks.
- Idiomas: **pt-BR padrão** (ABNT2, America/Sao_Paulo) + **en-US**, escolha no
  instalador e no primeiro boot, troca sem reinstalar. Strings próprias traduzíveis (gettext).
- Interface: GNOME com tema livre, dock inferior, barra superior, botões à esquerda, arte e sons originais.
- Otimização: zram, serviços enxutos, atualizações de segurança automáticas, firewall.
- Entrega: **ISO híbrida (UEFI + BIOS)** com instalador gráfico, bootável pelo **Ventoy**, SHA256 + assinatura GPG.
- Build reproduzível e versionado; licenças registradas; marca Debian sem sugerir endosso.
- **Critérios de aceitação:** boot sem erros em VM e PC físico (UEFI e legado,
  via Ventoy); instalador conclui nos dois idiomas; GNOME com tema, dock e
  barra; áudio, Wi-Fi, BT, vídeo e atalhos ok; `apt update && apt full-upgrade`
  sem erros; troca pt-BR ↔ en-US sem reinstalar.
- **Forma de trabalho pedida:** fases (1 base/build, 2 idiomas, 3 tema, 4
  drivers/otimização, 5 instalador/ISO, 6 testes/docs). Documentar cada decisão.
  **Antes de decisões difíceis de reverter (backports, instalador, licenças),
  apresentar opções e esperar confirmação.** Ao fim de cada fase: o que foi
  feito, o que falta e os riscos.

## 3. Decisões confirmadas pelo usuário

| Tema | Escolha do usuário | Onde está |
|---|---|---|
| Backports | **Só o kernel** vem do trixie-backports (pin 500 para `linux-image-* linux-headers-* linux-kbuild-* linux-base`; resto 100) | `docs/decisions/0002`, `config/archives/salph-backports.pref.chroot` |
| Instalador | **Calamares** | `0004`, `0008` |
| NVIDIA | **Fora da ISO**, instalado depois (`salph-drivers --install-nvidia`); `non-free` habilitado nas fontes | `0003`, `0007` |
| Tema | **Tema próprio sobre Adwaita** (sem WhiteSur, sem ícones que imitam a Apple) | `0006` |
| Apps padrão | **Firefox ESR + pt-BR, LibreOffice, GNOME Software, Flatpak + Flathub** (marcou todos) | `0006` |
| Licenças | **Código GPL-3.0-or-later; arte CC-BY-SA-4.0**; nome e logo SALPH identificam o projeto (forks devem trocar) | `LICENSE` |
| Onde compilar | **GitHub Actions** (o PC do usuário não tem admin nem Linux) | `.github/workflows/build-iso.yml` |

## 4. O que foi feito, fase a fase

### Fase 1 — Base e build
- `live-build` com tudo em `auto/config` + `config/`. ISO `iso-hybrid`, bootloaders `grub-efi,syslinux`, `--uefi-secure-boot enable` (shim/GRUB assinados do Debian).
- `build.sh`: `--version`, `--snapshot` (snapshot.debian.org para reprodutibilidade), `--sign KEYID` (GPG com o chaveiro do usuário do sudo), `--source` (ISO de código-fonte, obrigação da GPL) e `--clean`. Recusa build em `/mnt/c` (NTFS).
- Hook `9000-build-info` grava em `/usr/share/salph-os/build-info` a versão do Debian, o kernel e a data.

### Fase 2 — Idiomas
- Hook `0100`: gera só `pt_BR.UTF-8` e `en_US.UTF-8`; padrão pt-BR/ABNT2/São Paulo.
- Hook binário `0200`: adiciona a entrada **"SALPH OS Live (English, US)"** no GRUB e no ISOLINUX (detecta o nome real do kernel em `live/`).
- `gnome-initial-setup` no primeiro login do sistema instalado (pulado na sessão live).
- `src/salph-locale`: troca o idioma do sistema e do usuário (`localectl` + AccountsService).
- gettext: domínio `salph-os`, `po/pt_BR.po` e `po/en_US.po` (**26 mensagens, 100% traduzidas**), ferramenta `tools/l10n.sh pot|update|check|stage`.

### Fase 3 — Tema e interface
- dconf padrão (`/etc/dconf/db/local.d/00-salph-defaults`, não travado): botões `close,minimize,maximize:`, fontes Inter / JetBrains Mono, acento azul, wallpaper, sons, Dash to Dock (inferior, autohide, 48 px, translúcida), Blur my Shell na barra, AppIndicator.
- Extensão própria **`salph-look@salph-os.org`**: só `stylesheet.css` (barra compacta, menus e dock arredondados), `shell-version: ["48"]`.
- `tools/gen-assets.py` (só stdlib) gera: logo SVG (um "S" em onda num círculo azul degradê), wallpapers "Dunas" dia/noite (SVG), 9 sons WAV sintetizados e logos PNG (rasterizador próprio) para o Calamares e o Plymouth.
- `os-release` desviado com `dpkg-divert`: `NAME="SALPH OS"`, `ID=salph`, `ID_LIKE=debian`, `VERSION_CODENAME=trixie`. Sem URLs (o projeto ainda não tem site).
- Logo no GDM via `/etc/dconf/db/gdm.d/`.

### Fase 4 — Drivers e otimização
- Mesa, Vulkan, VA-API (Intel/AMD), switcheroo-control, fwupd, CUPS + ipp-usb.
- zram (`systemd-zram-generator`: 50% da RAM, máx. 8 GiB, zstd) + sysctl (`swappiness=180` etc.).
- Serviços: desativa `NetworkManager-wait-online`, `cups-browsed` e `thermald` no boot; ativa `fstrim.timer`. Journal limitado a 300 MB.
- `salph-hwprofile.service`: detecta notebook (chassi SMBIOS ou bateria) → thermald (Intel), economia de energia do áudio, writeback 15 s. Perfis pelo `power-profiles-daemon` (TLP descartado).
- `unattended-upgrades` diário (só segurança). **`salph-kernel-update.timer`**: atualiza só o kernel de backports, porque a equipe de segurança do Debian não cobre o backports.
- `salph-firstboot.service`: `ufw` (bloqueia entrada, libera saída e mDNS 5353/udp).
- `src/salph-drivers`: `--check`, `--install-nvidia` (usa `nvidia-detect`; com kernel de backports instala com `-t trixie-backports`; importa a chave MOK do DKMS se houver Secure Boot), `--notify` (aviso único no login).

### Fase 5 — Instalador e ISO
- Calamares 3.3.14 (**Qt6**) **não traz configuração padrão**, e o `calamares-settings-debian` traz marca Debian e QML do Qt5. Por isso foi criada uma **configuração completa própria** em `config/includes.chroot/etc/calamares/` (settings.conf, 16 módulos, branding `salph`, `show.qml` com 5 slides bilíngues).
- Partição: ext4 padrão; btrfs (subvolumes @, @home, @cache, @log) e xfs; criptografia **LUKS1** (o GRUB 2.12 não abre LUKS2/Argon2); sem swap por padrão (zram). Sem GeoIP.
- Scripts `usr/lib/salph-os/installer/`:
  - `prepare`: garante o kernel em /boot; purga live-boot, live-config e calamares; mantém os 2 locales; instala `grub-efi-amd64` (UEFI) ou `grub-pc` (BIOS) a partir de `.deb` guardados no squashfs (hook `0500` faz `apt-get download`).
  - `finish`: em UEFI, `grub-install --force-extra-removable` (fallback BOOTX64.EFI **com shim**); em BIOS, grava `grub-pc/install_devices` (by-id) no debconf, para o `apt full-upgrade` não perguntar.
- `bootloader.conf`: `efiBootloaderId: "salph"`, `installEFIFallback: false`.
- Sessão live: `salph-install` (sudo -E calamares, Wayland ou XWayland), ícone "Instalar o SALPH OS" como primeiro da dock (script live-config `1210`), `calamares.desktop` original escondido.
- Plymouth: tema `salph` (two-step, imagens do spinner do Debian + `watermark.png` SALPH).
- `docs/ventoy-secure-boot.md`: **não é preciso desativar o Secure Boot**; no Ventoy com "Suporte a Secure Boot", registrar a chave do Ventoy uma vez.

### Fase 6 — Testes e documentação
- `tests/qemu-run.sh <uefi|uefi-sb|bios>` (OVMF com chaves MS para Secure Boot), `--new-disk 40G` ou `--disk`.
- `tests/smoke-test.sh [--upgrade]`: PASS/FAIL/WARN dos critérios de aceitação no sistema instalado.
- `docs/testing.md` (matriz V1–V5 em VMs + F1/F2 físico via Ventoy, nos dois idiomas), `tests/RESULTS-template.md`.
- `docs/install.md` (uso pessoal + checklist de distribuição), `docs/packages-and-tweaks.md`, `CHANGELOG.md` bilíngue, `LICENSE`, `THIRD_PARTY.md`, `/usr/share/doc/salph-os/copyright` (formato DEP-5).

## 5. Build no GitHub Actions — estado atual

- Workflow: `.github/workflows/build-iso.yml`. Disparo manual (Actions → Build ISO → Run workflow, input `version`) ou push de tag `v*`.
  - Roda `debian:trixie` com `--privileged` e executa `./build.sh`.
  - Divide a ISO em partes de 1,9 GB (limite de 2 GB por arquivo do GitHub) e publica uma **Release pré-lançamento** `v<versão>`.
  - O `build.log` fica como artifact por 14 dias.
- **1º build (run 46049004092): a ISO foi gerada com sucesso.**
  - ISO de **2,1 GB**; **Debian 13.8**; **kernel 7.3.4+deb13-amd64** (backports).
  - Todos os hooks SALPH rodaram e as entradas en-US foram adicionadas ao GRUB e ao ISOLINUX.
  - Avisos normais de build em chroot: `grub-probe` e `cryptsetup` sem disco real.
  - Falhou só a publicação da Release: o glob `*.part*` casava também com `*.parts.sha256` (upload duplicado, HTTP 404). **Corrigido** para `*.part[0-9][0-9]`.
  - Também foi corrigido o volume ISO para `SALPH_OS`, porque o nome anterior violava ISO 9660.
- **2º build (run 46051794131): estava em andamento** quando este documento foi escrito.
  Conferir com `gh run list --workflow build-iso.yml` e `gh release view v0.1.0-alpha1`.
- Para juntar as partes no Windows:
  `cmd /c copy /b <iso>.part00+<iso>.part01 <iso>`
- A ISO de **código-fonte** (`--source`) **não** é gerada no workflow. Só será necessária ao distribuir publicamente.

## 6. Fatos verificados em packages.debian.org (2026-11-27)

GNOME Shell 48.7; Dash to Dock 100; Blur my Shell 67; Calamares 3.3.14 (Qt6);
kernel trixie 6.12.118 / **backports 7.3.4**; NVIDIA 550.163.01 (trixie e
backports); GRUB 2.12-9+deb13u4; plymouth 24.004.60. `grub-install` e
`update-grub` estão no pacote `grub2-common`, `grub-mkconfig` no `grub-common`.
O tema spinner do Plymouth **não tem** `watermark.png`.

## 7. Nada testado ainda — riscos a validar

1. **Boot real** da ISO em VM (UEFI, UEFI + Secure Boot, BIOS) e via Ventoy.
2. **Secure Boot com `EFI/salph`**: espera-se que o GRUB assinado do Debian leia o `grub.cfg` do próprio diretório. Se falhar, trocar para `debian` em `etc/calamares/modules/bootloader.conf` e `usr/lib/salph-os/installer/finish`.
3. **Calamares**: as chaves (`efi:`, `prefer_grub_d`, `style`, inline `component` no QML) foram escritas pela documentação da série 3.3, sem teste real. O YAML não foi validado com parser (PyYAML ausente no PC).
4. **Kernel em /boot no squashfs**: o `prepare` copia de `/live` se faltar.
5. NVIDIA: um kernel de backports novo pode sair antes do driver compatível.
6. O firewall bloqueia o ponto de acesso Wi-Fi (precisa de `ufw allow` manual).
7. O firmware do trixie é mais antigo que o kernel 7.3 (hardware muito novo pode precisar de firmware do backports).
8. A sessão live puxa dependências KDE Frameworks 6 por causa do Calamares (normal).

## 8. Próximos passos sugeridos

1. Confirmar que o 2º build publicou a Release; baixar e juntar as partes.
2. Testar em VM seguindo `docs/testing.md` e rodar `tests/smoke-test.sh` no sistema instalado.
3. Corrigir o que aparecer, em ciclos de build pelo Actions (cada um leva uns 40 min).
4. Definir o **PC físico de referência** e coletar `lspci -nn` e `lsusb` para ajustar firmware e drivers.
5. Antes de distribuir:
   - colocar os textos completos das licenças em `LICENSES/` (ver `LICENSES/README.md`);
   - gerar a ISO com `--source` e `--sign`;
   - criar a tag assinada;
   - decidir se o repositório vira público.
6. Ideias que ficaram para depois:
   - um botão/menu com o logo SALPH na barra superior (como o "menu da maçã"), que exigiria JS na extensão;
   - a opção do NVIDIA dentro do instalador (decisão 0003, opção B);
   - Mesa e firmware do backports se o hardware real exigir.

## 9. Convenções do projeto

- Cada decisão técnica vira um arquivo em `docs/decisions/NNNN-*.md` (status, motivo, riscos).
- Scripts voltados ao usuário (`src/`) usam gettext (`TEXTDOMAIN=salph-os`, msgid em inglês). Ferramentas de desenvolvedor (`build.sh`, `tools/`, `tests/`) usam mensagens bilíngues no próprio texto.
- Arquivos gerados no build ficam no `.gitignore`: WAVs, PNGs, `.mo`, `/usr/bin/*` staged, docs copiados.
- Scripts com bit executável no git (`git update-index --chmod=+x`); `.gitattributes` força LF.
- Commits terminam com `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. A identidade git local usa o e-mail *noreply* do GitHub do usuário.
- Não usar assets nem o nome da Apple; descrever sempre como "SALPH OS, baseado em Debian".

## 10. Linha do tempo da conversa (resumida)

1. O usuário colou a especificação completa → Fase 1. Ele escolheu: kernel-only backports, Calamares, NVIDIA pós-instalação.
2. "Start Phase 2" → idiomas.
3. "Start Phase 3" → escolheu tema próprio sobre Adwaita e os 4 grupos de apps.
4. "Start Phase 4" → drivers/otimização; descoberto o kernel 7.x no backports (pin corrigido).
5. "Start Phase 5" → Calamares com configuração própria (o Debian não fornece config Qt6), Plymouth, GPG, Ventoy.
6. "Start Phase 6" → confirmou as licenças; testes e docs.
7. "Gerou a ISO?" → não: o PC não tem Linux nem admin.
8. "Tem outro jeito?" → escolheu o **GitHub Actions** (já logado no `gh`). Criado o repositório privado, push, 1º build gerou a ISO (só falhou a publicação), corrigido, 2º build disparado.
9. O usuário confirmou que só queria o código no GitHub (a ISO de source da GPL fica para a distribuição) e pediu este documento.
