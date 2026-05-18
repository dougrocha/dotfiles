import QtQuick
import Quickshell
import qs.Constants

PopupWindow {
    id: root

    property string text: ""
    property Item targetItem: null
    property bool hovered: false
    property int delay: 500
    property int placement: Tooltip.Bottom
    property int offset: 4

    enum Placement {
        Bottom,
        Top,
        Left,
        Right
    }

    property bool shown: false
    visible: hovered && shown

    Timer {
        id: delayTimer
        interval: root.delay
        onTriggered: root.shown = true
    }

    onHoveredChanged: {
        if (hovered) {
            delayTimer.restart();
        } else {
            delayTimer.stop();
            shown = false;
        }
    }

    anchor.item: root.targetItem
    anchor.rect.x: {
        if (!targetItem)
            return 0;
        switch (placement) {
        case Tooltip.Left:
            return -implicitWidth - offset;
        case Tooltip.Right:
            return targetItem.width + offset;
        default:
            return Math.round(targetItem.width / 2 - implicitWidth / 2);
        }
    }
    anchor.rect.y: {
        if (!targetItem)
            return 0;
        switch (placement) {
        case Tooltip.Top:
            return -implicitHeight - offset;
        case Tooltip.Left:
        case Tooltip.Right:
            return Math.round(targetItem.height / 2 - implicitHeight / 2);
        default:
            return targetItem.height + offset;
        }
    }

    implicitWidth: label.implicitWidth + 16
    implicitHeight: label.implicitHeight + 8
    color: "transparent"

    property real reveal: visible ? 1.0 : 0.0
    Behavior on reveal {
        NumberAnimation {
            duration: root.visible ? 120 : 80
            easing.type: root.visible ? Easing.OutCubic : Easing.InCubic
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Colors.surface_container_high
        radius: 6
        opacity: root.reveal

        Text {
            id: label
            anchors.centerIn: parent
            text: root.text
            color: Colors.on_surface
            font.pixelSize: Fonts.p - 1
            font.family: Fonts.font
        }
    }
}
