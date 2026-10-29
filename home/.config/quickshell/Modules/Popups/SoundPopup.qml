pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.Components
import qs.Constants
import qs.Services

Popup {
    id: panel

    panelName: Visibilities.names.sound

    PanelHeader {
        title: "Sound"
    }

    PanelGroup {
        label: "Output"

        VolumeSlider {
            width: parent.width
            boundValue: AudioService.volume
            muted: AudioService.muted
            glyph: AudioService.speakerGlyph(AudioService.volume, AudioService.muted)
            onMoved: AudioService.setVolume(value)
        }

        Column {
            width: parent.width

            Repeater {
                model: ScriptModel {
                    values: AudioService.visibleSinks
                    objectProp: "id"
                }

                delegate: DeviceRow {
                    required property var modelData

                    glyph: AudioService.deviceIcon(modelData)
                    label: AudioService.shortLabel(modelData)
                    selected: modelData.id === AudioService.sink?.id
                    onTapped: AudioService.setAudioSink(modelData)
                }
            }
        }
    }

    PanelGroup {
        label: "Input"

        VolumeSlider {
            width: parent.width
            boundValue: AudioService.sourceVolume
            muted: AudioService.sourceMuted
            glyph: AudioService.sourceMuted ? PhosphorIcons.microphoneSlash : PhosphorIcons.microphone
            onMoved: AudioService.setSourceVolumeValue(value)
        }

        Column {
            width: parent.width

            Repeater {
                model: ScriptModel {
                    values: AudioService.visibleSources
                    objectProp: "id"
                }

                delegate: DeviceRow {
                    required property var modelData

                    glyph: AudioService.deviceIcon(modelData)
                    label: AudioService.shortLabel(modelData)
                    selected: modelData.id === AudioService.source?.id
                    onTapped: AudioService.setAudioSource(modelData)
                }
            }
        }
    }

    PanelGroup {
        label: "Apps"
        visible: AudioService.streamGroups.length > 0
        spacing: Theme.space.lg

        Repeater {
            model: ScriptModel {
                values: AudioService.streamGroups
                objectProp: "key"
            }

            delegate: Column {
                id: app

                required property var modelData
                readonly property bool muted: AudioService.getGroupMuted(modelData)
                readonly property real volume: AudioService.getGroupVolume(modelData)
                readonly property string playing: MprisService.nowPlayingFor(modelData.name)

                width: parent.width
                spacing: Theme.space.sm

                Item {
                    width: parent.width
                    height: appName.height

                    Text {
                        id: appName

                        width: Math.min(implicitWidth, parent.width)
                        text: app.modelData.name
                        textFormat: Text.PlainText
                        elide: Text.ElideRight
                        color: Theme.text.primary
                        font.family: Theme.font.ui
                        font.pixelSize: Theme.type.body.size
                    }

                    Text {
                        anchors.left: appName.right
                        anchors.leftMargin: Theme.space.sm
                        anchors.right: parent.right
                        anchors.baseline: appName.baseline
                        visible: app.playing !== ""
                        text: app.playing
                        textFormat: Text.PlainText
                        elide: Text.ElideRight
                        color: Theme.text.tertiary
                        font.family: Theme.font.ui
                        font.pixelSize: Theme.type.caption.size
                    }
                }

                VolumeSlider {
                    width: parent.width
                    boundValue: app.volume
                    muted: app.muted
                    glyph: AudioService.speakerGlyph(app.volume, app.muted)
                    onMoved: AudioService.setGroupVolume(app.modelData, value)
                }
            }
        }
    }

    PanelFooterLink {
        label: "Sound Settings…"
        command: ["launch-or-focus-tui", "wiremix"]
    }
}
