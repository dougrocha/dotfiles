import QtQuick
import qs.Constants

Rectangle {
    id: dot

    property bool pulsing: false

    width: Theme.island.dot
    height: Theme.island.dot
    radius: width / 2
    color: Theme.danger

    SequentialAnimation on opacity {
        running: dot.pulsing
        loops: Animation.Infinite
        NumberAnimation {
            to: 0.3
            duration: Theme.motion.pulse
        }
        NumberAnimation {
            to: 1
            duration: Theme.motion.pulse
        }
    }
}
