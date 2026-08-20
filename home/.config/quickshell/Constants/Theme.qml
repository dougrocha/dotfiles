pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property string primaryMonitor: "DP-1"

    // Falls back to the first screen, so an absent DP-1 doesn't take the bar's popups and the island with it.
    readonly property var primaryScreen: Quickshell.screens.find(s => s.name === primaryMonitor) ?? Quickshell.screens[0] ?? null

    // Variants model for the surfaces that exist once, not per monitor.
    readonly property var primaryScreens: primaryScreen ? [primaryScreen] : []

    property int blockHeight: 28
    property int blockRadius: 8
    property int panelMargin: 12

    property int cardHeight: 24

    readonly property QtObject notifications: QtObject {
        readonly property int panelWidth: 380
        readonly property int cardWidth: 360
        readonly property int cardHeight: 48
        readonly property int cardRadius: 16
        readonly property int spacing: 8
        readonly property int margin: 12
    }

    readonly property QtObject popup: QtObject {
        readonly property int radius: 12
        readonly property int gap: 6
        readonly property int margin: 12
        readonly property int spacing: 10
    }

    readonly property QtObject animations: QtObject {
        readonly property int fast: 150
        readonly property int normal: 200
        readonly property int slow: 300
    }

    readonly property int topBarHeight: 36
}
