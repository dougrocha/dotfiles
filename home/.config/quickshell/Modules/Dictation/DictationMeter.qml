pragma ComponentBehavior: Bound

import QtQuick
import qs.Constants
import qs.Services

Rectangle {
    id: meter

    readonly property int barCount: 11
    readonly property int barWidth: 3
    readonly property int barMinHeight: 4
    readonly property int barMaxHeight: 18
    readonly property int pillHeight: 34
    property var levels: Array(barCount).fill(0)
    property int head: 0
    property real wavePhase: 0

    function reset(): void {
        levels = Array(barCount).fill(0);
        head = 0;
    }

    function barLevel(index) {
        if (DictationService.transcribing)
            return 0.25 + 0.35 * (0.5 + 0.5 * Math.sin(wavePhase - index * 0.7));
        return levels[(head + index) % barCount] ?? 0;
    }

    implicitWidth: bars.implicitWidth + Theme.space.xl * 2
    implicitHeight: pillHeight
    radius: height / 2
    color: Theme.colors.bg
    border.width: 1
    border.color: Theme.stroke.strong

    Timer {
        interval: 40
        repeat: true
        running: DictationService.active
        onTriggered: {
            if (DictationService.recording) {
                meter.levels[meter.head] = DictationService.level;
                meter.head = (meter.head + 1) % meter.barCount;
            } else {
                meter.wavePhase += 0.35;
            }
        }
    }

    Row {
        id: bars

        anchors.centerIn: parent
        spacing: Theme.space.xs

        Repeater {
            model: meter.barCount

            Rectangle {
                required property int index

                anchors.verticalCenter: parent.verticalCenter
                width: meter.barWidth
                height: meter.barMinHeight + (meter.barMaxHeight - meter.barMinHeight) * meter.barLevel(index)
                radius: width / 2
                color: Theme.text.primary
                opacity: DictationService.transcribing ? 0.6 : 1

                Behavior on height {
                    NumberAnimation {
                        duration: Theme.motion.instant
                        easing.type: Theme.motion.easeSoft
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.motion.fast
                    }
                }
            }
        }
    }
}
