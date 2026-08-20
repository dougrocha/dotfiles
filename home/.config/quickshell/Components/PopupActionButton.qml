import QtQuick
import qs.Constants

// Footer row that hands the user off to a real settings app.
Rectangle {
    property string label: ""

    signal tapped

    width: parent.width
    height: 28
    radius: Theme.blockRadius
    color: buttonHover.hovered ? Colors.surface_container_high : "transparent"

    Behavior on color {
        ColorAnimation {
            duration: Theme.animations.fast
        }
    }

    Text {
        anchors.centerIn: parent
        text: parent.label
        color: buttonHover.hovered ? Colors.primary : Colors.on_surface_variant
        font.pixelSize: Fonts.small
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
