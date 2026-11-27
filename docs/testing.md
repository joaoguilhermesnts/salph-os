# Guia de testes / Testing guide

## Português (Brasil)

### Matriz mínima por versão
Cada linha precisa passar nos **dois idiomas** (entrada pt-BR e "English (US)"
do menu de boot) antes de publicar. Registre em `tests/RESULTS-template.md`.

| # | Ambiente | Firmware | Mídia |
|---|---|---|---|
| V1 | QEMU/KVM | UEFI | ISO |
| V2 | QEMU/KVM | UEFI + Secure Boot | ISO |
| V3 | QEMU/KVM | BIOS legado | ISO |
| V4 | VirtualBox 7 | UEFI e BIOS | ISO |
| V5 | VMware Workstation/Player 17 | UEFI e BIOS | ISO |
| F1 | PC de referência | UEFI + Secure Boot | Ventoy |
| F2 | PC de referência | Legado/CSM | Ventoy |

O PC de referência ainda não foi definido; anote modelo, `lspci -nn` e `lsusb`.

### QEMU (recomendado — cobre UEFI, Secure Boot e BIOS)
Num host Debian: `sudo apt install qemu-system-x86 qemu-utils ovmf`
```bash
# Instalar (cria tests/vm/<modo>.qcow2)
tests/qemu-run.sh uefi-sb --iso out/salph-os-<v>-amd64.hybrid.iso --new-disk 40G
tests/qemu-run.sh uefi    --iso out/salph-os-<v>-amd64.hybrid.iso --new-disk 40G
tests/qemu-run.sh bios    --iso out/salph-os-<v>-amd64.hybrid.iso --new-disk 40G
# Iniciar o sistema instalado
tests/qemu-run.sh uefi-sb --disk tests/vm/uefi-sb.qcow2
```
No modo `uefi-sb`, confirme que o Secure Boot está ativo: no sistema instalado,
`mokutil --sb-state` deve mostrar `SecureBoot enabled`.

### VirtualBox
Nova VM "Debian (64-bit)", 4 GB de RAM, 2+ CPUs, disco de 40 GB, vídeo
**VMSVGA** com 128 MB e aceleração 3D desligada. Teste duas vezes: com
*Sistema → Habilitar EFI* marcado (UEFI) e desmarcado (BIOS). Para Secure Boot
(VirtualBox 7+), marque também *Habilitar Secure Boot*.

### VMware
Nova VM "Debian 12.x 64-bit" (ou mais novo), 4 GB, 40 GB. Em *Opções → Avançado
→ Firmware* alterne entre **UEFI** (com ou sem *Secure Boot*) e **BIOS**.

### Hardware físico via Ventoy
Siga `docs/ventoy-secure-boot.md`. Faça F1 com Secure Boot ligado e F2 com o
modo legado (CSM) ativado no firmware, se o PC tiver.

### Roteiro por execução
1. **Boot da ISO:** menu aparece com as duas entradas; tela de boot SALPH;
   sessão live inicia em ~1 min sem mensagens de erro.
2. **Sessão live:** dock embaixo com "Instalar o SALPH OS" primeiro; barra
   superior com tema; som, rede e teclado funcionam.
3. **Instalação:** "Instalar o SALPH OS" → apagar disco (ext4) → usuário com
   senha de 8+ caracteres → concluir. Repita uma vez com **criptografia** e uma
   com **btrfs** por versão.
4. **Primeiro boot instalado:** menu GRUB "SALPH OS"; Plymouth; login no GDM
   com o logo; assistente de primeiro login do GNOME aparece.
5. **Verificação automática:** copie e rode `tests/smoke-test.sh` na sessão
   do usuário. Nenhum FAIL é aceito; WARNs precisam de justificativa.
6. **Verificação manual:**
   - tema, dock e barra superior; papel de parede claro/escuro;
   - atalhos: Super (visão geral), Alt+Tab, Super+setas, Print, volume/brilho;
   - áudio toca (Configurações → Som → Testar); vídeo no Firefox fluido;
   - Wi-Fi conecta e Bluetooth pareia (só em hardware físico);
   - `salph-locale en-US --keyboard us`, sair e entrar → tudo em inglês;
     voltar com `salph-locale pt-BR --keyboard br`;
   - `bash smoke-test.sh --upgrade` (roda `apt update && apt full-upgrade`)
     sem erros nem perguntas.
7. **Reinício e desligamento** limpos.

### Critérios de aceitação → como verificar
| Critério | Verificação |
|---|---|
| Boot sem erros em VM e físico, UEFI e legado | V1–V5, F1, F2, passo 1 e 4 |
| Instalador conclui nos dois idiomas | passo 3 com cada entrada do menu |
| GNOME com tema, dock e barra superior | smoke-test (Interface) + passo 6 |
| Áudio, Wi-Fi, Bluetooth, vídeo, atalhos | smoke-test (Hardware) + passo 6 |
| `apt update && apt full-upgrade` sem erros | `smoke-test.sh --upgrade` |
| Troca pt-BR ↔ en-US sem reinstalar | `salph-locale`, passo 6 |

### Se algo falhar
- Boot da ISO: remova `quiet splash` (tecla `e` no GRUB, Tab no ISOLINUX) para ver mensagens.
- Instalador: log em `/root/.cache/calamares/session.log` (sessão live) e
  `/var/log/installation.log` (sistema instalado).
- Secure Boot com `EFI/salph` falhando: ver riscos em `docs/decisions/0008-installer-and-iso.md`.

## English (US)

### Minimum matrix per release
Every row must pass in **both languages** (pt-BR entry and "English (US)" boot
entry) before publishing. Record results in `tests/RESULTS-template.md`.
Rows: V1 QEMU UEFI · V2 QEMU UEFI + Secure Boot · V3 QEMU BIOS · V4 VirtualBox
UEFI and BIOS · V5 VMware UEFI and BIOS · F1 reference PC UEFI + Secure Boot via
Ventoy · F2 reference PC legacy/CSM via Ventoy.

### QEMU
On a Debian host: `sudo apt install qemu-system-x86 qemu-utils ovmf`, then use
`tests/qemu-run.sh <uefi|uefi-sb|bios>` as shown above (`--new-disk 40G` to
install, `--disk tests/vm/<mode>.qcow2` to boot the installed system).

### VirtualBox / VMware
VirtualBox: "Debian (64-bit)", 4 GB RAM, VMSVGA 128 MB, no 3D; toggle
*System → Enable EFI* (and *Secure Boot* on 7+). VMware: "Debian 12.x 64-bit"
or newer; toggle *Options → Advanced → Firmware* between UEFI (± Secure Boot) and BIOS.

### Per-run checklist
1. ISO boot: both menu entries, SALPH splash, live session starts without errors.
2. Live session: "Install SALPH OS" first in the dock; sound, network, keyboard work.
3. Install: erase disk (ext4), user with 8+ character password. Once per
   release also with **encryption** and with **btrfs**.
4. Installed first boot: "SALPH OS" GRUB entry, splash, GDM logo, GNOME first-login setup.
5. Run `tests/smoke-test.sh` in the user session: zero FAILs.
6. Manual: theme/dock/top bar, shortcuts, audio, video, Wi-Fi, Bluetooth,
   language switch with `salph-locale`, `smoke-test.sh --upgrade`.
7. Clean reboot and shutdown.

The acceptance-criteria mapping table above applies to both languages.
