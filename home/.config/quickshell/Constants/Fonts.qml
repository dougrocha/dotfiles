pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell

Singleton {
    FontLoader {
        source: Quickshell.shellDir + "/assets/MaterialSymbolsOutlined_Filled-Regular.ttf"
    }

    FontLoader {
        source: Quickshell.shellDir + "/assets/MaterialSymbolsOutlined-Regular.ttf"
    }

    readonly property string font: "JetBrainsMono Nerd Font Propo"
    readonly property string iconFont: "Material Symbols Outlined Filled"
    readonly property string iconFontOutline: "Material Symbols Outlined"

    readonly property int p: 14
    readonly property int h1: 24
    readonly property int h2: 22
    readonly property int h3: 20
    readonly property int h4: 18
    readonly property int h5: 16
    readonly property int h6: 14
}
