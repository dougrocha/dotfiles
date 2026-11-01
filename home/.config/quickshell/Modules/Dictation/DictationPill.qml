import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Components
import qs.Constants
import qs.Services

PanelWindow {
    id: window

    readonly property int bottomMargin: 56
    property var hostScreen: Desktop.primaryScreen

    screen: window.hostScreen
    visible: presence.mapped
    color: "transparent"
    focusable: false

    WlrLayershell.namespace: "qs.dictation"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    anchors.bottom: true
    margins.bottom: window.bottomMargin

    implicitWidth: meter.implicitWidth
    implicitHeight: meter.pillHeight

    mask: Region {}

    Presence {
        id: presence

        active: DictationService.active
    }

    Connections {
        target: DictationService
        function onRecordingChanged() {
            if (DictationService.recording) {
                window.hostScreen = Desktop.focusedScreen();
                meter.reset();
            }
        }
    }

    DictationMeter {
        id: meter

        anchors.centerIn: parent
        opacity: presence.progress
        scale: presence.scale
    }
}
