import QtQuick
import qs.Constants

SequentialAnimation {
    id: swap

    required property Item target
    required property var source
    property var shown: ({})
    property real offset: 0

    onSourceChanged: {
        if (target.visible) {
            restart();
            return;
        }
        stop();
        shown = source;
        offset = 0;
        target.opacity = 1;
    }
    Component.onCompleted: shown = source

    ParallelAnimation {
        NumberAnimation {
            target: swap.target
            property: "opacity"
            to: 0
            duration: Theme.motion.instant
            easing.type: Theme.motion.easeExit
        }
        NumberAnimation {
            target: swap
            property: "offset"
            to: -Theme.space.xs
            duration: Theme.motion.instant
            easing.type: Theme.motion.easeExit
        }
    }
    ScriptAction {
        script: {
            swap.shown = swap.source;
            swap.offset = Theme.space.sm;
        }
    }
    ParallelAnimation {
        NumberAnimation {
            target: swap.target
            property: "opacity"
            to: 1
            duration: Theme.motion.normal
            easing.type: Theme.motion.easeStandard
        }
        NumberAnimation {
            target: swap
            property: "offset"
            to: 0
            duration: Theme.motion.normal
            easing.type: Theme.motion.easeStandard
        }
    }
}
