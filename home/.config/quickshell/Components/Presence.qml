import QtQuick
import Quickshell
import qs.Constants

Scope {
    id: presence

    required property bool active

    readonly property real progress: driver.value
    readonly property bool mapped: active || progress > 0
    readonly property real scale: Theme.motion.scaleFrom + (1 - Theme.motion.scaleFrom) * progress

    QtObject {
        id: driver

        property real value: presence.active ? 1 : 0

        Behavior on value {
            id: motion

            NumberAnimation {
                duration: Math.round((motion.targetValue > driver.value ? Theme.motion.normal : Theme.motion.fast) * Math.abs(motion.targetValue - driver.value))
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.motion.curveOut
            }
        }
    }
}
