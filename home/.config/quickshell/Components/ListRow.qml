import QtQuick
import qs.Constants

Rectangle {
    id: root

    property string label: ""
    property string glyph: ""
    property bool active: false
    property int bleed: 0
    default property alias trailing: trailingSlot.data

    signal tapped

    width: parent ? parent.width : implicitWidth
    height: 30
    radius: Theme.radius.sm
    color: "transparent"

    readonly property color fillColor: root.active ? Theme.fill.selected : rowHover.hovered ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

    Rectangle {
        z: -1
        anchors.fill: parent
        anchors.leftMargin: -root.bleed
        anchors.rightMargin: -root.bleed
        radius: root.radius
        color: root.fillColor

        Behavior on color {
            ColorAnimation {
                duration: Theme.motion.fast
            }
        }
    }

    Text {
        id: rowIcon
        visible: root.glyph !== ""
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        text: root.glyph
        color: root.active ? Theme.accent : Theme.text.secondary
        font.pixelSize: Theme.icon.sm
        font.family: Theme.font.icon

        Behavior on color {
            ColorAnimation {
                duration: Theme.motion.fast
            }
        }
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: rowIcon.visible ? rowIcon.right : parent.left
        anchors.leftMargin: rowIcon.visible ? 10 : 0
        anchors.right: trailingSlot.left
        anchors.rightMargin: Theme.space.md
        text: root.label
        color: Theme.text.primary
        font.pixelSize: Theme.type.body.size
        font.family: Theme.font.ui
        elide: Text.ElideRight
    }

    Row {
        id: trailingSlot
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
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
