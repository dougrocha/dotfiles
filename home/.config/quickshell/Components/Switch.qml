import QtQuick
import qs.Constants

Rectangle {
    id: root

    property bool active: false

    signal toggled

    implicitWidth: 32
    implicitHeight: 18
    radius: height / 2
    color: active ? Theme.accent : Theme.stroke.strong

    Behavior on color {
        ColorAnimation {
            duration: Theme.motion.fast
        }
    }

    Rectangle {
        y: 2
        x: root.active ? root.width - width - 2 : 2
        width: root.height - 4
        height: width
        radius: width / 2
        color: root.active ? Theme.accentText : Theme.text.secondary

        Behavior on x {
            NumberAnimation {
                duration: Theme.motion.fast
                easing.type: Theme.motion.easeStandard
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: Theme.motion.fast
            }
        }
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: root.toggled()
    }
}
