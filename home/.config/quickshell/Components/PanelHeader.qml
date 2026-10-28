import QtQuick
import qs.Constants

Item {
    id: header

    required property string title
    default property alias trailing: trailingSlot.data

    width: parent ? parent.width : implicitWidth
    implicitHeight: Math.max(titleText.implicitHeight, trailingSlot.implicitHeight)

    Text {
        id: titleText

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: header.title
        color: Theme.text.primary
        font.family: Theme.font.ui
        font.pixelSize: Theme.type.title.size
        font.weight: Theme.type.title.weight
    }

    Row {
        id: trailingSlot

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.space.sm
    }
}
