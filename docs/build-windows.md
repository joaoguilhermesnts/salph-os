# Build no Windows via WSL2 / Building on Windows with WSL2

1. PowerShell como administrador / as administrator:
   ```powershell
   wsl --install -d Debian
   ```
   Reinicie se pedido e crie o usuário Linux.

2. No terminal Debian / in the Debian shell:
   ```bash
   sudo apt update && sudo apt full-upgrade -y
   sudo apt install -y live-build git xorriso gettext python3 gnupg
   ```
   Confirme que é trixie: `cat /etc/debian_version` (deve começar com 13).

3. Copie o repositório para o sistema de arquivos Linux (não use `/mnt/c`):
   ```bash
   cp -r "/mnt/c/Users/<você>/Downloads/MW OS" ~/salph-os
   cd ~/salph-os
   sudo ./build.sh --version 0.1.0-alpha1
   ```

4. Resultado em `~/salph-os/out/`. Para copiar de volta:
   `cp out/* "/mnt/c/Users/<você>/Downloads/"`.

Espaço necessário: ~15 GB livres. Tempo: 20–60 min no primeiro build (cache acelera os seguintes).
