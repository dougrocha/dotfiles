import QtQuick
import qs.Constants

Rectangle {
    id: root

    property int bleed: 0

    x: -root.bleed
    width: parent.width + root.bleed * 2
    height: 1
    color: Theme.stroke.hairline
}
