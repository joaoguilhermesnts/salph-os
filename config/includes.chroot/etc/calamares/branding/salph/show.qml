/* SPDX-License-Identifier: GPL-3.0-or-later
 * SALPH OS — apresentação durante a instalação (Calamares 3.3, Qt6).
 * Textos em pt-BR quando a interface está em português; caso contrário en-US.
 */
import QtQuick
import calamares.slideshow 1.0

Presentation {
    id: presentation

    readonly property bool pt: Qt.uiLanguage.startsWith("pt") || Qt.locale().name.startsWith("pt")

    function nextSlide() { presentation.goToNextSlide(); }

    Timer {
        interval: 9000
        running: presentation.activatedInCalamares
        repeat: true
        onTriggered: nextSlide()
    }

    component SalphSlide: Slide {
        id: s
        property string heading
        property string body
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#1b2156" }
                GradientStop { position: 1.0; color: "#3b4bb0" }
            }
            Column {
                anchors.centerIn: parent
                width: parent.width * 0.8
                spacing: 18
                Text {
                    width: parent.width
                    text: s.heading
                    color: "#ffffff"
                    font.pixelSize: 30
                    font.weight: Font.DemiBold
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
                Text {
                    width: parent.width
                    text: s.body
                    color: "#dfe4ff"
                    font.pixelSize: 17
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    lineHeight: 1.25
                }
            }
        }
    }

    SalphSlide {
        heading: presentation.pt ? "Bem-vindo ao SALPH OS" : "Welcome to SALPH OS"
        body: presentation.pt
            ? "Um sistema estável, baseado em Debian, com um visual limpo e pensado para o dia a dia."
            : "A stable, Debian-based system with a clean look, built for everyday use."
    }
    SalphSlide {
        heading: presentation.pt ? "Dock e barra superior" : "Dock and top bar"
        body: presentation.pt
            ? "Seus apps ficam na dock, embaixo. Os controles de rede, som e energia ficam no canto superior direito."
            : "Your apps live in the dock at the bottom. Network, sound and power controls are at the top right."
    }
    SalphSlide {
        heading: presentation.pt ? "Apps e atualizações" : "Apps and updates"
        body: presentation.pt
            ? "Instale programas pelo app Programas (pacotes Debian e Flathub). As atualizações de segurança são automáticas."
            : "Install software from the Software app (Debian packages and Flathub). Security updates are automatic."
    }
    SalphSlide {
        heading: presentation.pt ? "Placa de vídeo NVIDIA?" : "NVIDIA graphics card?"
        body: presentation.pt
            ? "O driver proprietário é opcional. Depois de instalar, abra o Terminal e execute: salph-drivers --install-nvidia"
            : "The proprietary driver is optional. After installing, open Terminal and run: salph-drivers --install-nvidia"
    }
    SalphSlide {
        heading: presentation.pt ? "Português ou inglês" : "Portuguese or English"
        body: presentation.pt
            ? "Troque o idioma a qualquer momento em Configurações → Sistema → Região e idioma, sem reinstalar."
            : "Switch language any time in Settings → System → Region & Language, no reinstall needed."
    }

    function onActivate() { presentation.currentSlide = 0; }
    function onLeave() { }
}
