# 0004 — Instalador

**Status:** adotado / adopted · 2026-11-27

**Escolhida: A (Calamares).** Implementação descrita em 0008.

## Opções
**A. Calamares** (`calamares` + configuração própria em `calamares-settings-salph`).
Gráfico, já está no Debian `main`, é o que as imagens live oficiais usam,
suporta tradução pt-BR/en-US e branding próprio (licença GPL-3.0+).

**B. debian-installer gráfico.** Mais maduro para casos exóticos (RAID, LVM
complexo), mas visual fora da identidade e não roda dentro da sessão live.

**C. Ambos no menu de boot.** Mais cobertura, mais manutenção e ISO maior.

## Recomendação
A. Atende o requisito de instalador gráfico com seleção de idioma/teclado e
integra com a sessão live GNOME.
