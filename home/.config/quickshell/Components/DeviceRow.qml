import QtQuick
import qs.Constants

Rectangle {
    id: root

    property string label: ""
    property string icon: ""
    property bool active: false

    signal tapped

    width: parent.width
    height: 34
    radius: Theme.blockRadius
    color: rowHover.hovered ? Colors.surface_container_high : Colors.surface_container
    Behavior on color {
        ColorAnimation {
            duration: Theme.animations.fast
        }
    }

    Rectangle {
        id: iconBadge
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 6
        width: 22
        height: 22
        radius: 11
        color: root.active ? Colors.primary : "transparent"
        Behavior on color {
            ColorAnimation {
                duration: Theme.animations.fast
            }
        }

        Text {
            anchors.centerIn: parent
            text: root.icon
            color: root.active ? Colors.on_primary : Colors.on_surface_variant
            font.pixelSize: 13
            font.family: Fonts.phosphorFont
            Behavior on color {
                ColorAnimation {
                    duration: Theme.animations.fast
                }
            }
        }
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: iconBadge.right
        anchors.leftMargin: 8
        anchors.right: parent.right
        anchors.rightMargin: 10
        text: root.label
        color: Colors.on_surface
        font.pixelSize: Fonts.body.size
        font.family: Fonts.font
        elide: Text.ElideRight
    }

    HoverHandler {
        id: rowHover
        cursorShape: Qt.PointingHandCursor
    }
    TapHandler {
        onTapped: root.tapped()
    }
}
