import QtQuick
import qs.Constants

Rectangle {
    id: root

    property string label: ""
    property string glyph: ""
    property bool active: false
    default property alias trailing: trailingSlot.data

    signal tapped

    width: parent ? parent.width : implicitWidth
    height: 34
    radius: Theme.radius.md
    color: root.active ? Theme.fill.selected : rowHover.hovered ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

    Behavior on color {
        ColorAnimation {
            duration: Theme.motion.instant
        }
    }

    Rectangle {
        id: badge
        visible: root.glyph !== ""
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Theme.space.md
        width: 22
        height: 22
        radius: width / 2
        color: root.active ? Theme.fill.selectedSolid : Theme.withAlpha(Theme.fill.selectedSolid, 0)

        Behavior on color {
            ColorAnimation {
                duration: Theme.motion.instant
            }
        }

        Text {
            anchors.centerIn: parent
            text: root.glyph
            color: root.active ? Theme.accentText : Theme.text.secondary
            font.pixelSize: Theme.icon.xxs
            font.family: Theme.font.icon

            Behavior on color {
                ColorAnimation {
                    duration: Theme.motion.instant
                }
            }
        }
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: badge.visible ? badge.right : parent.left
        anchors.leftMargin: badge.visible ? Theme.space.md : Theme.space.lg
        anchors.right: trailingSlot.left
        anchors.rightMargin: Theme.space.md
        text: root.label
        color: root.active ? Theme.text.primary : Theme.text.secondary
        font.pixelSize: Theme.type.body.size
        font.family: Theme.font.ui
        elide: Text.ElideRight
    }

    Row {
        id: trailingSlot
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Theme.space.md
        spacing: Theme.space.xs
    }

    HoverHandler {
        id: rowHover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: root.tapped()
    }
}
