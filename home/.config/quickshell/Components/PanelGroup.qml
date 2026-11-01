import QtQuick
import qs.Constants

Column {
    id: group

    required property string label

    width: parent ? parent.width : implicitWidth
    spacing: Theme.space.xs

    Text {
        text: group.label
        color: Theme.text.tertiary
        font.family: Theme.font.ui
        font.pixelSize: Theme.type.label.size
        font.weight: Theme.type.label.weight
    }
}
