# 0006 — Tema, interface e aplicativos padrão

**Status:** adotado / adopted · 2026-11-27

## Tema: próprio, sobre Adwaita
- **GTK:** Adwaita/libadwaita do GNOME 48, com cor de acento azul. Não há
  tema GTK de terceiros: apps GTK4/libadwaita ignoram temas GTK, e forçar um
  tema quebra a cada atualização. Cantos arredondados e animações já vêm do
  Adwaita.
- **GNOME Shell:** extensão própria `salph-look@salph-os.org`, que só carrega
  um `stylesheet.css` (barra compacta, menus e dock arredondados, Inter). Sem
  código, então o risco de quebrar entre atualizações é mínimo. Fica
  desativável em Extensões.
- **Ícones e cursor:** Adwaita. Não usamos conjuntos que imitam ícones da Apple.
- **Fontes:** Inter (interface) e JetBrains Mono (terminal), ambas SIL OFL 1.1.
- **Botões de janela à esquerda:** `button-layout='close,minimize,maximize:'`.
- **Dock:** Dash to Dock (pacote Debian), inferior, ocultar com inteligência,
  ícones 48 px, fundo translúcido. Desfoque da barra superior por Blur my Shell.
  AppIndicator para ícones de bandeja.
- **Padrões em dconf** (`/etc/dconf/db/local.d/`), não travados — o usuário
  pode mudar tudo; "Restaurar padrão" volta para os valores do SALPH OS.

## Identidade
- Logo, wallpapers "Dunas" (claro/escuro) e sons gerados por
  `tools/gen-assets.py` — 100% originais e reproduzíveis.
- `/usr/lib/os-release` desviado com `dpkg-divert`: `NAME="SALPH OS"`,
  `ID=salph`, `ID_LIKE=debian`, `VERSION_CODENAME=trixie`. O original do Debian
  fica em `/usr/lib/os-release.debian`. Atualizações do `base-files` não
  sobrescrevem o nosso.

## Aplicativos padrão
Firefox ESR (pt-BR), LibreOffice Writer/Calc/Impress (pt-BR, ajuda pt-BR/en-US),
GNOME Software com suporte a Flatpak, e o remoto **Flathub** habilitado.

## Riscos
- Flathub é fonte de terceiros, fora do controle de segurança do Debian;
  apps Flatpak têm licenças próprias, exibidas no GNOME Software.
- O CSS do Shell usa seletores do GNOME 48 e do Dash to Dock 100. Uma nova
  versão estável do Debian exigirá revisão (o `shell-version` da extensão
  impede que ela carregue em versões não testadas).
- LibreOffice + Firefox aumentam a ISO em ~450 MB (estimativa: 3–3,5 GB no total).
- Não foi possível ver a arte renderizada neste ambiente; validar no primeiro boot.
