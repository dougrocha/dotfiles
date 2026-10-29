import QtQuick
import qs.Constants

PanelRow {
    id: row

    required property string glyph
    required property string label
    property string detail: ""
    property bool selected: false
    default property alias trailing: trailingSlot.data

    implicitHeight: Math.max(34, labels.implicitHeight + Theme.space.sm * 2)

    Rectangle {
        id: badge

        anchors.verticalCenter: parent.verticalCenter
        width: 26
        height: 26
        radius: height / 2
        color: row.selected ? Theme.accent : Theme.fill.press

        Behavior on color {
            ColorAnimation {
                duration: Theme.motion.fast
            }
        }

        Text {
            anchors.centerIn: parent
            text: row.glyph
            color: row.selected ? Theme.accentText : Theme.text.primary
            font.family: Theme.font.iconFill
            font.pixelSize: Theme.icon.xs
        }
    }

    Column {
        id: labels

        anchors.left: badge.right
        anchors.leftMargin: Theme.space.md
        anchors.right: trailingSlot.left
        anchors.rightMargin: trailingSlot.width > 0 ? Theme.space.sm : 0
        anchors.verticalCenter: parent.verticalCenter

        Text {
            width: parent.width
            text: row.label
            textFormat: Text.PlainText
            elide: Text.ElideRight
            color: Theme.text.primary
            font.family: Theme.font.ui
            font.pixelSize: Theme.type.body.size
        }

        Text {
            visible: row.detail !== ""
            width: parent.width
            text: row.detail
            textFormat: Text.PlainText
            elide: Text.ElideRight
            color: Theme.text.tertiary
            font.family: Theme.font.ui
            font.pixelSize: Theme.type.caption.size
        }
    }

    Row {
        id: trailingSlot

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.space.xs
    }
}
