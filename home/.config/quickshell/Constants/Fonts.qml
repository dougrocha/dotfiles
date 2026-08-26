pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell

Singleton {
    FontLoader {
        source: Quickshell.shellDir + "/assets/MaterialSymbolsOutlined_Filled-Regular.ttf"
    }

    FontLoader {
        source: Quickshell.shellDir + "/assets/Phosphor.ttf"
    }

    FontLoader {
        source: Quickshell.shellDir + "/assets/Phosphor-Fill.ttf"
    }

    readonly property string font: "JetBrainsMono Nerd Font Propo"
    readonly property string iconFont: "Material Symbols Outlined Filled"
    readonly property string phosphorFont: "Phosphor"
    readonly property string phosphorFill: "Phosphor-Fill"

    readonly property int p: 14
    readonly property int caption: 11
    readonly property int h2: 22
    readonly property int h3: 20
    readonly property int h4: 18
    readonly property int h5: 16

    readonly property QtObject title: QtObject {
        readonly property int size: 14
        readonly property int weight: Font.Medium
    }
    readonly property QtObject body: QtObject {
        readonly property int size: 12
        readonly property int weight: Font.Normal
    }
    readonly property QtObject label: QtObject {
        readonly property int size: 11
        readonly property int weight: Font.Medium
    }
}
