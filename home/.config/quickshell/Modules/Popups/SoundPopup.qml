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
        spacing: Theme.space.sm

        Item {
            width: parent.width
            height: 24

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "Sound"
                color: Theme.text.primary
                font.pixelSize: Theme.type.display.size
                font.weight: Theme.type.display.weight
                font.family: Theme.font.ui
            }
        }

        Column {
            width: parent.width
            spacing: Theme.space.sm

            Text {
                text: "Output"
                color: Theme.text.primary
                font.pixelSize: Theme.type.body.size
                font.weight: Font.Medium
                font.family: Theme.font.ui
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
                spacing: Theme.space.xxs

                Repeater {
                    model: ScriptModel {
                        values: AudioService.sinks
                        objectProp: "id"
                    }

                    delegate: ListRow {
                        required property var modelData
                        width: parent.width
                        label: AudioService.shortLabel(modelData)
                        glyph: AudioService.deviceIcon(modelData)
                        active: AudioService.sink && modelData.id === AudioService.sink.id
                        onTapped: AudioService.setAudioSink(modelData)
                    }
                }
            }
        }

        Divider {}

        Column {
            width: parent.width
            spacing: Theme.space.sm

            Text {
                text: "Input"
                color: Theme.text.primary
                font.pixelSize: Theme.type.body.size
                font.weight: Font.Medium
                font.family: Theme.font.ui
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
                spacing: Theme.space.xxs

                Repeater {
                    model: ScriptModel {
                        values: AudioService.sources
                        objectProp: "id"
                    }

                    delegate: ListRow {
                        required property var modelData
                        width: parent.width
                        label: AudioService.shortLabel(modelData)
                        glyph: AudioService.deviceIcon(modelData)
                        active: AudioService.source && modelData.id === AudioService.source.id
                        onTapped: AudioService.setAudioSource(modelData)
                    }
                }
            }
        }

        Column {
            width: parent.width
            spacing: Theme.space.sm
            visible: AudioService.streamGroups.length > 0

            Divider {}

            Text {
                text: "Apps"
                color: Theme.text.secondary
                font.pixelSize: Theme.type.caption.size
                font.weight: Font.Medium
                font.family: Theme.font.ui
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
                    muteIcon: PhosphorIcons.speakerHigh
                    mutedIcon: PhosphorIcons.speakerSlash
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
