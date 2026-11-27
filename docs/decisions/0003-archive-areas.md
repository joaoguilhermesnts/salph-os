# 0003 — Componentes do arquivo Debian e driver NVIDIA

**Status:** adotado / adopted · 2026-11-27

**Escolhida: A.** Fontes: `main contrib non-free non-free-firmware`; nenhum pacote non-free na ISO.

## Opções para o driver NVIDIA proprietário (opcional)
**A. Não incluir na ISO.** Sources do sistema instalado já trazem `non-free`;
o usuário instala `nvidia-driver` depois, com um guia na documentação. ISO 100%
livre exceto firmware.

**B. Pacotes `.deb` no pool da ISO, instalados pelo Calamares só se o usuário
marcar a opção e uma GPU NVIDIA for detectada.** Exige `non-free` no build e
DKMS + headers; com Secure Boot, o módulo precisa ser assinado (MOK).

## Recomendação
A para a 0.1; B como evolução na Phase 5, se houver usuários com NVIDIA.
