pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.Components
import qs.Constants
import qs.Services

PanelWindow {
    id: window

    readonly property int barCount: 11
    readonly property int barWidth: 3
    readonly property int barMinHeight: 4
    readonly property int barMaxHeight: 18
    readonly property int pillHeight: 34
    readonly property int bottomMargin: 56
    property string monitorName: ""
    property var levels: Array(barCount).fill(0)
    property int head: 0
    property real wavePhase: 0

    screen: Quickshell.screens.find(s => s.name === window.monitorName) ?? Theme.primaryScreen
    visible: presence.mapped
    color: "transparent"
    focusable: false

    WlrLayershell.namespace: "qs.dictation"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    anchors.bottom: true
    margins.bottom: window.bottomMargin

    implicitWidth: pill.width
    implicitHeight: window.pillHeight

    mask: Region {}

    Presence {
        id: presence

        active: DictationService.active
    }

    Connections {
        target: DictationService
        function onRecordingChanged() {
            if (DictationService.recording) {
                window.monitorName = Hyprland.focusedMonitor?.name ?? "";
                window.levels = Array(window.barCount).fill(0);
                window.head = 0;
            }
        }
    }

    Timer {
        interval: 40
        repeat: true
        running: DictationService.active
        onTriggered: {
            if (DictationService.recording) {
                window.levels[window.head] = DictationService.level;
                window.head = (window.head + 1) % window.barCount;
            } else {
                window.wavePhase += 0.35;
            }
        }
    }

    function barLevel(index) {
        if (DictationService.transcribing)
            return 0.25 + 0.35 * (0.5 + 0.5 * Math.sin(wavePhase - index * 0.7));
        return levels[(head + index) % barCount] ?? 0;
    }

    Rectangle {
        id: pill

        anchors.centerIn: parent
        width: bars.implicitWidth + Theme.space.xl * 2
        height: window.pillHeight
        radius: height / 2
        color: Theme.colors.bg
        border.width: 1
        border.color: Theme.stroke.strong
        opacity: presence.progress
        scale: presence.scale

        Row {
            id: bars

            anchors.centerIn: parent
            spacing: Theme.space.xs

            Repeater {
                model: window.barCount

                Rectangle {
                    required property int index

                    anchors.verticalCenter: parent.verticalCenter
                    width: window.barWidth
                    height: window.barMinHeight + (window.barMaxHeight - window.barMinHeight) * window.barLevel(index)
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
}
