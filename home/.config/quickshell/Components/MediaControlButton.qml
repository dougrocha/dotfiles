import QtQuick
import qs.Constants

// Transport button; `filled` gives the primary action its disc.
Rectangle {
    property string icon: ""
    property int iconSize: 28
    property bool filled: false

    signal tapped

    width: filled ? 40 : 28
    height: width
    radius: filled ? width / 2 : 0
    color: filled ? Qt.rgba(Colors.on_surface.r, Colors.on_surface.g, Colors.on_surface.b, 0.15) : "transparent"

    Text {
        anchors.centerIn: parent
        text: parent.icon
        color: buttonHover.hovered ? Colors.primary : Colors.on_surface
        font.pixelSize: parent.iconSize
        font.family: Fonts.iconFont

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
