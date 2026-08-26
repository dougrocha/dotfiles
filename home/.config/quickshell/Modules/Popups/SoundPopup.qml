import QtQuick
import Quickshell
import Quickshell.Io
import qs.Components
import qs.Constants
import qs.Services

Popup {
    id: panel

    shown: Visibilities.soundPanel
    onDismissed: Visibilities.soundPanel = false

    Column {
        width: parent.width
        spacing: 6

        Item {
            width: parent.width
            height: 24

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "Sound"
                color: Colors.on_surface
                font.pixelSize: 16
                font.weight: Font.Medium
                font.family: Fonts.font
            }
        }

        Column {
            width: parent.width
            spacing: 6

            Text {
                text: "Output"
                color: Colors.on_surface
                font.pixelSize: Fonts.body.size
                font.weight: Font.Medium
                font.family: Fonts.font
            }

            StyledSlider {
                width: parent.width
                height: 26
                from: 0
                to: 1
                boundValue: AudioService.volume
                onMoved: AudioService.setVolume(value)
            }

            Column {
                width: parent.width
                visible: AudioService.sinks.length > 1
                spacing: 2

                Repeater {
                    model: ScriptModel {
                        values: AudioService.sinks
                        objectProp: "id"
                    }

                    delegate: DeviceRow {
                        required property var modelData
                        width: parent.width
                        label: AudioService.shortLabel(modelData)
                        icon: AudioService.deviceIcon(modelData)
                        active: AudioService.sink && modelData.id === AudioService.sink.id
                        onTapped: AudioService.setAudioSink(modelData)
                    }
                }
            }
        }

        Divider {}

        Column {
            width: parent.width
            spacing: 6

            Text {
                text: "Input"
                color: Colors.on_surface
                font.pixelSize: Fonts.body.size
                font.weight: Font.Medium
                font.family: Fonts.font
            }

            StyledSlider {
                width: parent.width
                height: 26
                from: 0
                to: 1
                boundValue: AudioService.sourceVolume
                onMoved: AudioService.setSourceVolumeValue(value)
            }

            Column {
                width: parent.width
                visible: AudioService.sources.length > 1
                spacing: 2

                Repeater {
                    model: ScriptModel {
                        values: AudioService.sources
                        objectProp: "id"
                    }

                    delegate: DeviceRow {
                        required property var modelData
                        width: parent.width
                        label: AudioService.shortLabel(modelData)
                        icon: AudioService.deviceIcon(modelData)
                        active: AudioService.source && modelData.id === AudioService.source.id
                        onTapped: AudioService.setAudioSource(modelData)
                    }
                }
            }
        }

        Column {
            width: parent.width
            spacing: 6
            visible: AudioService.streamGroups.length > 0

            Divider {}

            Text {
                text: "Apps"
                color: Colors.on_surface_variant
                font.pixelSize: Fonts.caption
                font.weight: Font.Medium
                font.family: Fonts.font
            }

            Repeater {
                model: ScriptModel {
                    values: AudioService.streamGroups
                    objectProp: "key"
                }

                delegate: SlimSlider {
                    required property var modelData

                    width: parent.width
                    iconSource: modelData.icon
                    labelText: modelData.name
                    sublabelText: MprisService.nowPlayingFor(modelData.name)
                    sliderValue: AudioService.getGroupVolume(modelData)
                    muted: AudioService.getGroupMuted(modelData)
                    muteIcon: Icons.volumeUp
                    mutedIcon: Icons.volumeMute
                    onMoved: value => AudioService.setGroupVolume(modelData, value)
                    onMuteToggled: AudioService.setGroupMuted(modelData, !AudioService.getGroupMuted(modelData))
                }
            }
        }

        PopupActionButton {
            label: "Wiremix"
            leftAlign: true
            onTapped: {
                Visibilities.soundPanel = false;
                soundSettingsProc.running = true;
            }
        }
    }

    Process {
        id: soundSettingsProc
        command: ["launch-or-focus-tui", "wiremix"]
    }
}
