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

        Column {
            width: parent.width
            spacing: Theme.space.sm

            SectionLabel {
                text: "OUTPUT"
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
                visible: AudioService.visibleSinks.length > 0
                spacing: Theme.space.xxs

                Repeater {
                    model: ScriptModel {
                        values: AudioService.visibleSinks
                        objectProp: "id"
                    }

                    delegate: ListRow {
                        required property var modelData
                        width: parent.width
                        bleed: panel.rowBleed
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

            SectionLabel {
                text: "INPUT"
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
                visible: AudioService.visibleSources.length > 0
                spacing: Theme.space.xxs

                Repeater {
                    model: ScriptModel {
                        values: AudioService.visibleSources
                        objectProp: "id"
                    }

                    delegate: ListRow {
                        required property var modelData
                        width: parent.width
                        bleed: panel.rowBleed
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

            SectionLabel {
                text: "APPS"
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

        Divider {}

        PopupActionButton {
            label: "Wiremix"
            bleed: panel.rowBleed
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
