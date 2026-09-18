import QtQuick
import qs.Constants

Rectangle {
    id: root

    property bool revealed: false

    signal tapped

    width: 20
    height: 20
    radius: width / 2
    color: Theme.colors.raised
    border.width: 1
    border.color: badgeHover.hovered ? Theme.stroke.accent : Theme.stroke.hairline
    opacity: root.revealed || badgeHover.hovered ? 1 : 0
    enabled: opacity > 0

    Behavior on opacity {
        NumberAnimation {
            duration: Theme.motion.fast
        }
    }
    Behavior on border.color {
        ColorAnimation {
            duration: Theme.motion.fast
        }
    }

    Text {
        anchors.centerIn: parent
        text: PhosphorIcons.x
        font.family: Theme.font.icon
        font.pixelSize: Theme.icon.xxs
        color: badgeHover.hovered ? Theme.text.primary : Theme.text.secondary

        Behavior on color {
            ColorAnimation {
                duration: Theme.motion.fast
            }
        }
    }

    HoverHandler {
        id: badgeHover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: root.tapped()
    }
}
