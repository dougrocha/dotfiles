import QtQuick
import qs.Constants

Rectangle {
    property bool hovered: false

    anchors.centerIn: parent
    width: parent.width
    height: Theme.bar.plateHeight
    radius: Theme.bar.plateRadius
    color: hovered ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

    Behavior on color {
        ColorAnimation {
            duration: Theme.motion.fast
        }
    }
}
