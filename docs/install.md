# Instalação e distribuição / Installation and distribution

## Português (Brasil)

### Parte 1 — Uso pessoal

**Requisitos:** PC 64 bits (amd64), 2 GB de RAM (4 GB recomendados), 20 GB de
disco, pendrive de 8 GB. Funciona com UEFI (com ou sem Secure Boot) e BIOS legado.

1. **Baixe e confira** a ISO, o `.sha256` e, se houver, os `.asc`:
   `sha256sum -c salph-os-<v>-amd64.hybrid.iso.sha256`
2. **Crie o pendrive:** copie a ISO para um pendrive com Ventoy
   (`docs/ventoy-secure-boot.md`) ou grave-a direto com Rufus (modo DD),
   balenaEtcher ou `dd`.
3. **Dê boot** pelo pendrive (tecla de menu de boot: F12, F11, F8 ou Esc,
   depende do fabricante). Escolha **SALPH OS Live** (português) ou
   **SALPH OS Live (English, US)**.
4. **Experimente** o sistema; nada é gravado no disco.
5. **Instale:** primeiro ícone da dock, "Instalar o SALPH OS".
   - *Apagar disco* é o mais simples. Marque *Criptografar sistema* para
     proteger seus dados se o computador for roubado (a senha é pedida a cada boot).
   - *Lado a lado* mantém o Windows; o menu do GRUB oferece os dois sistemas.
   - Escolha nome de usuário e senha (8+ caracteres). Essa senha é usada
     para tarefas de administrador (`sudo`).
6. **Reinicie** e remova o pendrive quando pedido.

**Primeiros passos**
- O assistente do GNOME aparece no primeiro login (idioma, teclado, privacidade).
- Atualizações de segurança são automáticas. Outras aparecem no app **Programas**.
- **Placa NVIDIA:** abra o Terminal e rode `salph-drivers --install-nvidia`
  (detalhes do Secure Boot em `docs/ventoy-secure-boot.md`).
- **Trocar idioma:** Configurações → Sistema → Região e idioma, ou
  `salph-locale en-US --keyboard us` (e `pt-BR --keyboard br` para voltar).
- **Firewall:** ativo, bloqueia conexões de entrada. Para liberar um serviço:
  `sudo ufw allow <porta>`.
- **Apps extras:** app Programas (pacotes Debian e Flathub).

### Parte 2 — Distribuir o SALPH OS

**Antes de publicar uma versão**
1. Tag no git: `git tag -s v<versão>`; build a partir da tag, com snapshot:
   ```bash
   sudo ./build.sh --version <v> --snapshot <AAAAMMDDTHHMMSSZ> --sign <KEYID> --source
   ```
2. Confira a point release do Debian em `/usr/share/salph-os/build-info` (dentro
   da ISO) com debian.org/releases e registre no `CHANGELOG.md`.
3. Rode a matriz completa de `docs/testing.md` e anexe os resultados.
4. Publique **juntos**: ISO, `.sha256`, `.asc` da ISO e do checksum, chave
   pública (`salph-os-signing-key.asc`), ISO de código-fonte, changelog e o
   link para este repositório na tag correspondente.

**Licenças e obrigações**
- **Código-fonte:** a ISO contém programas GPL do Debian. Ao distribuir a
  ISO, ofereça o código-fonte correspondente: a ISO de código-fonte gerada com
  `--source` cumpre isso. Os scripts e configurações do SALPH OS estão neste
  repositório (GPL-3.0-or-later).
- **Arte (logo, wallpapers, sons):** CC-BY-SA-4.0. O nome "SALPH OS" e o logo
  identificam o projeto. Quem fizer uma versão modificada deve usar outro nome
  e outro logo para não confundir os usuários.
- **Firmware não livre** (`non-free-firmware`) é redistribuível pelas licenças
  dos fabricantes, já incluídas em `/usr/share/doc/firmware-*/copyright`.
- **Driver NVIDIA:** não vai na ISO; o usuário instala a partir do Debian.
- **Marcas:** descreva sempre como "SALPH OS, baseado em Debian". Não use o
  logo do Debian, não diga que é oficial ou endossado pelo Projeto Debian, e
  não use "macOS", "Apple" ou qualquer arte da Apple.
- **Firefox:** distribuímos o binário do Debian sem modificações, o que a
  política de marcas da Mozilla permite.
- Tabela completa de componentes e licenças: `THIRD_PARTY.md`.

**Textos completos das licenças:** antes da primeira publicação, copie para
`LICENSES/` (num host Debian):
```bash
cp /usr/share/common-licenses/GPL-3 LICENSES/GPL-3.0-or-later.txt
# CC-BY-SA-4.0: texto legal oficial de creativecommons.org/licenses/by-sa/4.0/legalcode.txt
```

## English (US)

### Part 1 — Personal use
**Requirements:** 64-bit PC, 2 GB RAM (4 GB recommended), 20 GB disk, 8 GB USB
drive. UEFI (with or without Secure Boot) or legacy BIOS.

1. Download the ISO and `.sha256` (and `.asc`), verify with `sha256sum -c`.
2. Put the ISO on a Ventoy drive (`docs/ventoy-secure-boot.md`) or write it
   directly with Rufus (DD mode), balenaEtcher or `dd`.
3. Boot from USB and pick **SALPH OS Live (English, US)** or the pt-BR entry.
4. Try it out; nothing is written to disk.
5. Click "Install SALPH OS" (first dock icon). *Erase disk* is simplest; tick
   *Encrypt system* to protect your data; *Install alongside* keeps Windows.
6. Reboot and remove the USB drive when asked.

**First steps:** GNOME first-login setup runs once; security updates are
automatic; NVIDIA users run `salph-drivers --install-nvidia`; switch language
in Settings → System → Region & Language or with `salph-locale`; the firewall
blocks incoming connections (`sudo ufw allow <port>` to open one).

### Part 2 — Distributing SALPH OS
Build from a signed git tag with `--snapshot`, `--sign` and `--source`; check
the Debian point release in `/usr/share/salph-os/build-info`; run the full
`docs/testing.md` matrix; publish the ISO, checksums, signatures, public key,
**source ISO** and changelog together. Code is GPL-3.0-or-later, artwork
CC-BY-SA-4.0; modified redistributions must use a different name and logo.
Always say "SALPH OS, based on Debian", never imply Debian endorsement, and
never use Apple names or artwork. Full component/license table: `THIRD_PARTY.md`.
