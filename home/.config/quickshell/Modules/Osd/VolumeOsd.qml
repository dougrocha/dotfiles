pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Constants
import qs.Services

// On volume or mute changes, slides a click-through pill up from the bottom
// of the primary screen, holds briefly, then fades. Lives on the overlay
// layer so it stays visible above fullscreen windows, where the bar's hover
// strip is unreachable.
Variants {
    id: root
    model: Quickshell.screens

    delegate: PanelWindow {
        id: osd

        required property var modelData
        screen: modelData

        color: "transparent"
        anchors {
            bottom: true
        }
        implicitWidth: 320
        implicitHeight: 110
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs.osd"
        mask: Region {}

        visible: modelData.name === Theme.primaryMonitor

        // "volume" or "mic"
        property string mode: "volume"
        property bool shown: false
        readonly property bool micMode: mode === "mic"
        readonly property bool muted: micMode ? AudioService.sourceMuted : AudioService.muted
        readonly property real level: micMode ? AudioService.sourceVolume : AudioService.volume

        // Swallow the property changes PipeWire emits while the shell (re)loads.
        property bool ready: false
        Timer {
            interval: 1000
            running: true
            onTriggered: osd.ready = true
        }

        Timer {
            id: hideTimer
            interval: 1200
            onTriggered: osd.shown = false
        }

        function show(newMode) {
            if (!ready || modelData.name !== Theme.primaryMonitor)
                return;
            mode = newMode;
            shown = true;
            hideTimer.restart();
        }

        Connections {
            target: AudioService.sink?.audio ?? null
            function onVolumeChanged() {
                osd.show("volume");
            }
            function onMutedChanged() {
                osd.show("volume");
            }
        }

        Connections {
            target: AudioService.source?.audio ?? null
            function onMutedChanged() {
                osd.show("mic");
            }
        }

        Rectangle {
            id: pill
            width: 280
            height: 44
            radius: height / 2
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: osd.shown ? 48 : 30
            color: Colors.surface_container_low
            border.width: 1
            border.color: Colors.outline_variant
            opacity: osd.shown ? 1 : 0
            antialiasing: true

            Behavior on anchors.bottomMargin {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on opacity {
                NumberAnimation {
                    duration: osd.shown ? 150 : 250
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 18
                anchors.rightMargin: 18
                spacing: 12

                Text {
                    Layout.alignment: Qt.AlignVCenter
                    font.family: Fonts.phosphorFont
                    font.pixelSize: 18
                    color: osd.muted ? Colors.on_surface_variant : Colors.on_surface
                    text: {
                        if (osd.micMode)
                            return osd.muted ? PhosphorIcons.microphoneSlash : PhosphorIcons.microphone;
                        if (osd.muted)
                            return PhosphorIcons.speakerSlash;
                        if (osd.level === 0)
                            return PhosphorIcons.speakerNone;
                        return osd.level < 0.5 ? PhosphorIcons.speakerLow : PhosphorIcons.speakerHigh;
                    }
                }

                // Track: 0-100% fills in primary; the 100-150% boost range
                // refills the same track in tertiary.
                Rectangle {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    implicitHeight: 6
                    radius: 3
                    color: Qt.rgba(Colors.on_surface_variant.r, Colors.on_surface_variant.g, Colors.on_surface_variant.b, 0.25)

                    Rectangle {
                        width: parent.width * Math.min(osd.level, 1)
                        height: parent.height
                        radius: parent.radius
                        color: osd.muted ? Colors.on_surface_variant : Colors.primary

                        Behavior on width {
                            NumberAnimation {
                                duration: 120
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width * Math.max(0, Math.min((osd.level - 1) / 0.5, 1))
                        height: parent.height
                        radius: parent.radius
                        color: Colors.tertiary

                        Behavior on width {
                            NumberAnimation {
                                duration: 120
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignVCenter
                    font.family: Fonts.font
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    color: Colors.on_surface
                    text: osd.muted ? "Muted" : (osd.micMode ? "Live" : Math.round(osd.level * 100) + "%")
                }
            }
        }
    }
}
