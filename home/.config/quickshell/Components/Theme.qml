import QtQuick
import Quickshell
pragma Singleton

Singleton {
    id: theme

    property int blockHeight: 18
    property int blockRadius: 8
    property string fontFamily: "JetBrainsMono Mono Nerd"
    property int fontSize: 14
    property string iconFontFamily: "Material Symbols Outlined"
}
