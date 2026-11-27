// SPDX-License-Identifier: GPL-3.0-or-later
// SALPH Look: o GNOME Shell carrega stylesheet.css desta extensão quando ela
// está ativa e o remove ao desativar. Nenhuma lógica extra é necessária, o que
// mantém a extensão segura entre atualizações do Shell.
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';

export default class SalphLookExtension extends Extension {
    enable() {}
    disable() {}
}
