import QtQuick
import qs.Constants

Rectangle {
    id: track

    property real fraction: 0
    property color fillColor: Theme.text.primary
    property int fillDuration: Theme.motion.normal

    height: Theme.control.track
    radius: Theme.radius.track
    color: Theme.stroke.strong

    Rectangle {
        width: track.fraction * track.width
        height: track.height
        radius: Theme.radius.track
        color: track.fillColor

        Behavior on width {
            NumberAnimation {
                duration: track.fillDuration
                easing.type: Theme.motion.easeStandard
            }
        }
    }
}
