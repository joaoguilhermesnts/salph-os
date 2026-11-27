# Ventoy e Secure Boot / Ventoy and Secure Boot

## Português (Brasil)

### Pendrive com Ventoy
1. Instale o Ventoy no pendrive (uma vez) com o Ventoy2Disk, disponível em ventoy.net.
   Se o computador usa Secure Boot, marque **Opção → Suporte a Secure Boot** antes de instalar.
2. Copie `salph-os-<versão>-amd64.hybrid.iso` para a partição do pendrive, como
   qualquer arquivo. Não é preciso formatar nem extrair nada.
3. Confira o arquivo antes de usar (opcional, recomendado):
   ```bash
   sha256sum -c salph-os-<versão>-amd64.hybrid.iso.sha256
   gpg --import salph-os-signing-key.asc
   gpg --verify salph-os-<versão>-amd64.hybrid.iso.sha256.asc
   ```
4. Dê boot pelo pendrive, escolha a ISO no menu do Ventoy e depois
   "SALPH OS Live" (português) ou "SALPH OS Live (English, US)".

### Secure Boot: é preciso desativar?
**Não.** A ISO usa o `shim` e o GRUB assinados do Debian, aceitos pelos PCs
com a chave da Microsoft (padrão de fábrica). O que depende do caminho de boot:

| Como dá boot | Secure Boot ligado |
|---|---|
| ISO gravada direto no pendrive (dd, Rufus modo DD, Etcher) ou em VM | Funciona sem ação extra |
| Ventoy **com** "Suporte a Secure Boot" | Na **primeira vez** aparece uma tela azul (MokManager) ou "Verification failed". Registre a chave do Ventoy uma única vez: *Enroll key from disk* → `VTOYEFI` → `ENROLL_THIS_KEY_IN_MOKMANAGER.cer` → *Continue* → *Yes* → *Reboot*. Depois disso, inicia normalmente. |
| Ventoy **sem** "Suporte a Secure Boot" | Não inicia. Reinstale o Ventoy com a opção ou desative o Secure Boot no firmware. |

Desativar o Secure Boot também funciona, mas não é recomendado para uso diário.

### Depois de instalado
- O sistema instalado continua com Secure Boot (shim + GRUB + kernel assinados
  pelo Debian, inclusive o kernel de backports).
- **NVIDIA:** o driver proprietário é um módulo compilado na máquina (DKMS).
  `salph-drivers --install-nvidia` pede uma senha temporária; no reinício,
  escolha *Enroll MOK* na tela azul e digite essa senha.
- Se o menu do Ventoy não iniciar a ISO em algum PC específico, teste o modo
  GRUB2 do Ventoy (atalho indicado no rodapé do menu do Ventoy).

## English (US)

### Ventoy USB drive
1. Install Ventoy on the USB drive (once) with Ventoy2Disk from ventoy.net.
   If the PC uses Secure Boot, tick **Option → Secure Boot Support** first.
2. Copy `salph-os-<version>-amd64.hybrid.iso` to the drive like any file. No
   formatting or extraction needed.
3. Verify the download (optional, recommended): see the `sha256sum` / `gpg`
   commands above.
4. Boot from the drive, pick the ISO in Ventoy, then "SALPH OS Live"
   (Portuguese) or "SALPH OS Live (English, US)".

### Secure Boot: must it be disabled?
**No.** The ISO uses Debian's signed `shim` and GRUB, trusted by PCs with the
Microsoft key (factory default).

| Boot path | Secure Boot on |
|---|---|
| ISO written directly (dd, Rufus DD mode, Etcher) or in a VM | Works, nothing to do |
| Ventoy **with** "Secure Boot Support" | **First time only**: a blue screen (MokManager) or "Verification failed" appears. Enroll Ventoy's key once: *Enroll key from disk* → `VTOYEFI` → `ENROLL_THIS_KEY_IN_MOKMANAGER.cer` → *Continue* → *Yes* → *Reboot*. |
| Ventoy **without** "Secure Boot Support" | Won't boot. Reinstall Ventoy with the option, or disable Secure Boot in firmware. |

### After installation
- The installed system keeps Secure Boot (Debian-signed shim, GRUB and kernel,
  backports kernel included).
- **NVIDIA:** the proprietary driver is a locally built module (DKMS).
  `salph-drivers --install-nvidia` asks for a one-time password; on reboot pick
  *Enroll MOK* on the blue screen and type it.
- If Ventoy fails to boot the ISO on a given PC, try Ventoy's GRUB2 mode
  (hotkey shown at the bottom of the Ventoy menu).
