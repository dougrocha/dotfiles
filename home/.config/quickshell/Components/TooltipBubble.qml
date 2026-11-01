import QtQuick
import qs.Constants

Rectangle {
    id: bubble

    property string text: ""
    implicitWidth: label.implicitWidth + Theme.row.gap * 2
    implicitHeight: label.implicitHeight + Theme.space.xs * 2
    radius: Theme.radius.small
    color: Theme.colors.raised
    border.color: Theme.stroke.strong
    border.width: 1

    Text {
        id: label
        anchors.centerIn: parent
        text: bubble.text
        color: Theme.text.primary
        renderType: Text.NativeRendering
        font.pixelSize: Theme.type.body.size
        font.family: Theme.font.ui
    }
}
