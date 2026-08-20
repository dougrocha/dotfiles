import QtQuick
import Quickshell
import Quickshell.Io
import qs.Components
import qs.Constants
import qs.Services

PopupWindow {
    id: panel

    color: "transparent"

    implicitWidth: card.cardWidth
    implicitHeight: card.height

    mask: Region {
        item: card
    }

    visible: Visibilities.soundPanel

    PopupGrab {
        popup: panel
        onDismissed: Visibilities.soundPanel = false
    }

    PopupCard {
        id: card

        readonly property int cardWidth: 260

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        shown: Visibilities.soundPanel
        onDismissed: Visibilities.soundPanel = false

        Text {
            text: "Sound"
            color: Colors.on_surface
            font.pixelSize: Fonts.h4
            font.family: Fonts.font
            font.weight: Font.DemiBold
        }

        Item {
            width: parent.width
            height: 20

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: AudioService.muted ? Icons.volumeMute : Icons.volumeUp
                color: Colors.primary
                font.pixelSize: Fonts.h5
                font.family: Fonts.iconFont
                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }
                TapHandler {
                    onTapped: AudioService.toggleMute()
                }
            }

            StyledSlider {
                anchors.left: parent.left
                anchors.leftMargin: 26
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                from: 0
                to: 1
                boundValue: AudioService.volume
                onMoved: AudioService.setVolume(value)
            }
        }

        PopupDivider {}

        SectionLabel {
            text: "OUTPUT"
        }

        Column {
            width: parent.width
            spacing: 2

            Repeater {
                model: ScriptModel {
                    values: AudioService.sinks
                    objectProp: "id"
                }

                delegate: DeviceRow {
                    required property var modelData
                    label: AudioService.shortLabel(modelData)
                    active: AudioService.sink && modelData.id === AudioService.sink.id
                    onTapped: AudioService.setAudioSink(modelData)
                }
            }
        }

        PopupDivider {}

        SectionLabel {
            text: "INPUT"
        }

        Item {
            width: parent.width
            height: 20

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: AudioService.sourceMuted ? Icons.micOff : Icons.mic
                color: Colors.primary
                font.pixelSize: Fonts.h5
                font.family: Fonts.iconFont
                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }
                TapHandler {
                    onTapped: AudioService.toggleSourceMute()
                }
            }

            StyledSlider {
                anchors.left: parent.left
                anchors.leftMargin: 26
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                from: 0
                to: 1
                boundValue: AudioService.sourceVolume
                onMoved: AudioService.setSourceVolumeValue(value)
            }
        }

        Column {
            width: parent.width
            spacing: 2

            Repeater {
                model: ScriptModel {
                    values: AudioService.sources
                    objectProp: "id"
                }

                delegate: DeviceRow {
                    required property var modelData
                    label: AudioService.shortLabel(modelData)
                    active: AudioService.source && modelData.id === AudioService.source.id
                    onTapped: AudioService.setAudioSource(modelData)
                }
            }
        }

        // Per-app sliders are the only ones that boost past 100%.
        Column {
            width: parent.width
            spacing: Theme.popup.spacing
            visible: AudioService.streamGroups.length > 0

            PopupDivider {}

            SectionLabel {
                text: "SOURCES"
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

        PopupDivider {}

        PopupActionButton {
            label: "Sound Settings…"
            onTapped: {
                Visibilities.soundPanel = false;
                soundSettingsProc.running = true;
            }
        }

        Process {
            id: soundSettingsProc
            command: ["launch-or-focus-tui", "wiremix"]
        }
    }
}
