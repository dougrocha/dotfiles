pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: theme

    // Colors
    property color bg: "#1a1b26"
    property color fg: "#a9b1d6"
    property color muted: "#444b6a"
    property color cyan: "#0db9d7"
    property color purple: "#ad8ee6"
    property color red: "#f7768e"
    property color yellow: "#e0af68"
    property color blue: "#7aa2f7"

    // Fonts
    property string fontFamily: "JetBrainsMono Nerd Font Propo"
    property string iconFontFamily: "Material Symbols Outlined"
    property int fontSize: 14

    // Spacing/Sizing
    property int blockHeight: 18
    property int blockRadius: 8
    property int panelHeight: 45
    property int panelMargin: 5
}
