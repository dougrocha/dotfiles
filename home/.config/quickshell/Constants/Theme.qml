pragma Singleton
import QtQuick
import Quickshell

Singleton {
    // Sizing
    property int blockHeight: 28
    property int blockRadius: 8
    property int panelHeight: 36
    property int panelMargin: 12

    // Card
    property int cardHeight: 24

    readonly property QtObject notifications: QtObject {
        readonly property int panelWidth: 380
        readonly property int cardWidth: 360
        readonly property int cardHeight: 48
        readonly property int spacing: 8
        readonly property int margin: 12
    }
}
