import QtQuick
import qs.Constants

// Footer row that hands the user off to a real settings app.
Rectangle {
    property string label: ""
    property bool leftAlign: false

    signal tapped

    width: parent.width
    height: 28
    radius: Theme.blockRadius
    color: buttonHover.hovered ? Colors.surface_container_high : Colors.surface_container

    Behavior on color {
        ColorAnimation {
            duration: Theme.animations.fast
        }
    }

    Text {
        anchors.left: parent.leftAlign ? parent.left : undefined
        anchors.leftMargin: parent.leftAlign ? 10 : 0
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.leftAlign ? undefined : parent.horizontalCenter
        text: parent.label
        color: buttonHover.hovered ? Colors.primary : Colors.on_surface_variant
        font.pixelSize: Fonts.body.size
        font.family: Fonts.font

        Behavior on color {
            ColorAnimation {
                duration: Theme.animations.fast
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
