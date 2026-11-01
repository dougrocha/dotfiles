import QtQuick
import qs.Constants

PanelRow {
    id: row

    required property string label
    property string detail: ""
    property bool selected: false
    default property alias trailing: trailingSlot.data

    implicitHeight: Math.max(Theme.row.menu, labels.implicitHeight + Theme.space.sm * 2)

    Column {
        id: labels

        anchors.left: parent.left
        anchors.right: trailingSlot.left
        anchors.rightMargin: Theme.space.sm
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

        Text {
            visible: row.selected
            anchors.verticalCenter: parent.verticalCenter
            text: PhosphorIcons.check
            color: Theme.text.primary
            font.family: Theme.font.icon
            font.pixelSize: Theme.icon.xs
        }
    }
}
