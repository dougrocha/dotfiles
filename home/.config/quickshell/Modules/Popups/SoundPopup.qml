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

    component MuteButton: Rectangle {
        id: muteButton

        property bool muted: false
        property string iconText: ""
        property string mutedIconText: ""

        signal tapped

        activeFocusOnTab: true
        width: 40
        height: 40
        radius: width / 2
        color: muteHover.hovered || activeFocus ? Colors.surface_container_highest : Colors.surface_container
        border.width: activeFocus ? 1 : 0
        border.color: muted ? Colors.error : Colors.primary

        Behavior on color {
            ColorAnimation {
                duration: Theme.animations.fast
            }
        }

        Text {
            anchors.centerIn: parent
            text: muteButton.muted ? muteButton.mutedIconText : muteButton.iconText
            color: muteButton.muted ? Colors.error : Colors.primary
            font.pixelSize: 17
            font.family: Fonts.iconFont
        }

        HoverHandler {
            id: muteHover
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler {
            onTapped: muteButton.tapped()
        }
        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                muteButton.tapped();
                event.accepted = true;
            }
        }
    }

    PopupCard {
        id: card

        readonly property int cardWidth: 300

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        shown: Visibilities.soundPanel
        onDismissed: Visibilities.soundPanel = false

        Item {
            width: parent.width
            height: 28

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "Sound"
                color: Colors.on_surface
                font.pixelSize: 16
                font.weight: Font.Medium
                font.family: Fonts.font
            }

            Rectangle {
                id: closeButton
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 28
                height: 28
                radius: 14
                activeFocusOnTab: true
                color: closeHover.hovered || activeFocus ? Colors.surface_container_highest : Colors.surface_container
                border.width: activeFocus ? 1 : 0
                border.color: Colors.primary

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animations.fast
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: Icons.closeSmall
                    color: closeHover.hovered || closeButton.activeFocus ? Colors.on_surface : Colors.on_surface_variant
                    font.pixelSize: 18
                    font.family: Fonts.iconFont
                }

                HoverHandler {
                    id: closeHover
                    cursorShape: Qt.PointingHandCursor
                }
                TapHandler {
                    onTapped: Visibilities.soundPanel = false
                }
                Keys.onPressed: function (event) {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                        Visibilities.soundPanel = false;
                        event.accepted = true;
                    }
                }
            }
        }

        PopupDivider {}

        Column {
            width: parent.width
            spacing: 8

            Column {
                width: parent.width
                spacing: 1

                Text {
                    text: "Output"
                    color: Colors.on_surface
                    font.pixelSize: Fonts.small
                    font.weight: Font.Medium
                    font.family: Fonts.font
                }

                Text {
                    width: parent.width
                    text: AudioService.sink ? AudioService.shortLabel(AudioService.sink) : "No output device"
                    color: Colors.on_surface_variant
                    font.pixelSize: Fonts.caption
                    font.family: Fonts.font
                    elide: Text.ElideRight
                }
            }

            Row {
                width: parent.width
                height: 40
                spacing: 10

                MuteButton {
                    muted: AudioService.muted
                    iconText: Icons.volumeUp
                    mutedIconText: Icons.volumeMute
                    onTapped: AudioService.toggleMute()
                }

                StyledSlider {
                    width: parent.width - 40 - outputPercent.width - 20
                    height: parent.height
                    from: 0
                    to: 1
                    boundValue: AudioService.volume
                    onMoved: AudioService.setVolume(value)
                }

                Text {
                    id: outputPercent
                    width: 34
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    text: Math.round(AudioService.volume * 100) + "%"
                    color: AudioService.muted ? Colors.error : Colors.on_surface_variant
                    font.pixelSize: Fonts.small
                    font.family: Fonts.font
                }
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
                        active: AudioService.sink && modelData.id === AudioService.sink.id
                        onTapped: AudioService.setAudioSink(modelData)
                    }
                }
            }
        }

        PopupDivider {}

        Column {
            width: parent.width
            spacing: 8

            Column {
                width: parent.width
                spacing: 1

                Text {
                    text: "Input"
                    color: Colors.on_surface
                    font.pixelSize: Fonts.small
                    font.weight: Font.Medium
                    font.family: Fonts.font
                }

                Text {
                    width: parent.width
                    text: AudioService.source ? AudioService.shortLabel(AudioService.source) : "No input device"
                    color: Colors.on_surface_variant
                    font.pixelSize: Fonts.caption
                    font.family: Fonts.font
                    elide: Text.ElideRight
                }
            }

            Row {
                width: parent.width
                height: 40
                spacing: 10

                MuteButton {
                    muted: AudioService.sourceMuted
                    iconText: Icons.mic
                    mutedIconText: Icons.micOff
                    onTapped: AudioService.toggleSourceMute()
                }

                StyledSlider {
                    width: parent.width - 40 - inputPercent.width - 20
                    height: parent.height
                    from: 0
                    to: 1
                    boundValue: AudioService.sourceVolume
                    onMoved: AudioService.setSourceVolumeValue(value)
                }

                Text {
                    id: inputPercent
                    width: 34
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    text: Math.round(AudioService.sourceVolume * 100) + "%"
                    color: AudioService.sourceMuted ? Colors.error : Colors.on_surface_variant
                    font.pixelSize: Fonts.small
                    font.family: Fonts.font
                }
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
                        active: AudioService.source && modelData.id === AudioService.source.id
                        onTapped: AudioService.setAudioSource(modelData)
                    }
                }
            }
        }

        Column {
            width: parent.width
            spacing: 8
            visible: AudioService.streamGroups.length > 0

            PopupDivider {}

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
