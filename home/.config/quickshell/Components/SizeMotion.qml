import QtQuick
import qs.Constants

Behavior {
    id: motion

    readonly property real current: targetProperty.object ? targetProperty.object[targetProperty.name] ?? 0 : 0
    readonly property bool growing: targetValue > current

    NumberAnimation {
        duration: motion.growing ? Theme.motion.normal : Theme.motion.fast
        easing.type: Theme.motion.easeStandard
    }
}
