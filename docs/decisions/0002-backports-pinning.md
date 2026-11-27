# 0002 — Uso de trixie-backports

**Status:** adotado / adopted · 2026-11-27

**Escolhida: B.** Pinning em `config/archives/salph-backports.pref.chroot` (build) e `config/includes.chroot/etc/apt/preferences.d/` (sistema instalado).

## Opções
**A. Sem backports na ISO (atual).** Só trixie + security + updates. Máxima
estabilidade; hardware lançado depois do kernel do trixie pode não funcionar.

**B. Backports habilitado com prioridade 100 e pacotes específicos fixados em 500.**
Repositório presente, mas nada vem de lá por padrão; apenas a lista abaixo:
```
Package: linux-image-* linux-headers-* linux-kbuild-* linux-base
Pin: release n=trixie-backports
Pin-Priority: 500
```
Mesa e firmware ficam no trixie. Recomendado se o hardware de referência for recente.

**C. Como B, incluindo Mesa e firmware-*.** Melhor suporte a GPUs novas, porém
Mesa de backports puxa várias libs (libdrm, llvm) — maior risco em `full-upgrade`.

## Recomendação
B. Kernel de backports é o caso mais seguro e mais útil; Mesa só se o hardware
real exigir (decidir na Phase 4 com `lspci -nn`).
