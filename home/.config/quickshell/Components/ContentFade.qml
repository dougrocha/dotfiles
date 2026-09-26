import QtQuick
import qs.Constants

Behavior {
    id: fade

    readonly property bool entering: fade.targetValue > 0

    SequentialAnimation {
        PauseAnimation {
            duration: fade.entering ? Theme.motion.enterDelay : 0
        }
        NumberAnimation {
            duration: fade.entering ? Theme.motion.normal : Theme.motion.instant
            easing.type: fade.entering ? Theme.motion.easeStandard : Theme.motion.easeExit
        }
    }
}
