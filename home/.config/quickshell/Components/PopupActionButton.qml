import QtQuick
import qs.Constants

Rectangle {
    id: root

    property string label: ""
    property string glyph: PhosphorIcons.terminal
    property int bleed: 0

    signal tapped

    readonly property bool highlighted: buttonHover.hovered || activeFocus

    activeFocusOnTab: true
    width: parent.width
    height: 30
    radius: Theme.radius.sm
    color: "transparent"

    Rectangle {
        z: -1
        anchors.fill: parent
        anchors.leftMargin: -root.bleed
        anchors.rightMargin: -root.bleed
        radius: parent.radius
        color: root.highlighted ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

        Behavior on color {
            ColorAnimation {
                duration: Theme.motion.fast
            }
        }
    }

    Text {
        id: actionIcon
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: root.glyph
        color: root.highlighted ? Theme.accent : Theme.text.secondary
        font.pixelSize: Theme.icon.sm
        font.family: Theme.font.icon

        Behavior on color {
            ColorAnimation {
                duration: Theme.motion.fast
            }
        }
    }

    Text {
        anchors.left: actionIcon.right
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: root.label
        color: Theme.text.primary
        font.pixelSize: Theme.type.body.size
        font.family: Theme.font.ui
        elide: Text.ElideRight
    }

    HoverHandler {
        id: buttonHover
        cursorShape: Qt.PointingHandCursor
    }
    TapHandler {
        onTapped: root.tapped()
    }
    Keys.onPressed: function (event) {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            root.tapped();
            event.accepted = true;
        }
    }
}
