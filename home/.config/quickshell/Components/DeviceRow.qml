import QtQuick
import qs.Constants

Rectangle {
    property string label: ""
    property bool active: false

    signal tapped

    width: parent.width
    height: Theme.blockHeight
    radius: Theme.blockRadius
    color: rowHover.hovered ? Colors.surface_container_high : Colors.surface_container
    Behavior on color {
        ColorAnimation {
            duration: Theme.animations.fast
        }
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10
        width: 6
        height: 6
        radius: 3
        color: parent.active ? Colors.primary : Colors.outline
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.right: parent.right
        anchors.rightMargin: 10
        text: parent.label
        color: parent.active ? Colors.primary : Colors.on_surface_variant
        font.pixelSize: Fonts.small
        font.family: Fonts.font
        font.weight: parent.active ? Font.Medium : Font.Normal
        elide: Text.ElideRight
    }

    HoverHandler {
        id: rowHover
        cursorShape: Qt.PointingHandCursor
    }
    TapHandler {
        onTapped: parent.tapped()
    }
}
