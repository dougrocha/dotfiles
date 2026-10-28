import QtQuick
import qs.Constants

PanelRow {
    id: root

    property string label: ""
    property string glyph: PhosphorIcons.terminal

    implicitHeight: 30

    Text {
        id: actionIcon

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: root.glyph
        color: root.highlighted ? (root.danger ? Theme.danger : Theme.accent) : Theme.text.secondary
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
}
