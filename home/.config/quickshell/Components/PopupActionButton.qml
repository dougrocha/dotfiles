import QtQuick
import qs.Constants

Rectangle {
    property string label: ""
    property bool leftAlign: false

    signal tapped

    width: parent.width
    height: 28
    radius: Theme.radius.md
    color: buttonHover.hovered ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)
    border.width: 1
    border.color: Theme.stroke.hairline

    Behavior on color {
        ColorAnimation {
            duration: Theme.motion.instant
        }
    }

    Text {
        anchors.left: parent.leftAlign ? parent.left : undefined
        anchors.leftMargin: parent.leftAlign ? Theme.space.lg : 0
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.leftAlign ? undefined : parent.horizontalCenter
        text: parent.label
        color: buttonHover.hovered ? Theme.text.primary : Theme.text.secondary
        font.pixelSize: Theme.type.label.size
        font.family: Theme.font.ui
        font.weight: Theme.type.label.weight

        Behavior on color {
            ColorAnimation {
                duration: Theme.motion.instant
            }
        }
    }

    HoverHandler {
        id: buttonHover
        cursorShape: Qt.PointingHandCursor
    }
    TapHandler {
        onTapped: parent.tapped()
    }
}
