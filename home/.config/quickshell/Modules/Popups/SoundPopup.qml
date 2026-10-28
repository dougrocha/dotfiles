pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.Components
import qs.Constants
import qs.Services

Popup {
    id: panel

    function speakerGlyph(volume, muted) {
        if (muted || volume <= 0)
            return PhosphorIcons.speakerSlash;
        return volume < 0.5 ? PhosphorIcons.speakerLow : PhosphorIcons.speakerHigh;
    }

    panelName: "sound-panel"

    Column {
        width: parent.width
        spacing: Theme.space.xl

        Text {
            text: "Sound"
            color: Theme.text.primary
            font.family: Theme.font.ui
            font.pixelSize: Theme.type.title.size
            font.weight: Theme.type.title.weight
        }

        SoundGroup {
            label: "Output"

            VolumeSlider {
                width: parent.width
                boundValue: AudioService.volume
                muted: AudioService.muted
                glyph: panel.speakerGlyph(AudioService.volume, AudioService.muted)
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
                        selected: modelData.id === AudioService.sink?.id
                        onChosen: AudioService.setAudioSink(modelData)
                    }
                }
            }
        }

        SoundGroup {
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
                        selected: modelData.id === AudioService.source?.id
                        onChosen: AudioService.setAudioSource(modelData)
                    }
                }
            }
        }

        SoundGroup {
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
                        glyph: panel.speakerGlyph(app.volume, app.muted)
                        onMoved: AudioService.setGroupVolume(app.modelData, value)
                    }
                }
            }
        }

        Column {
            width: parent.width
            spacing: Theme.space.sm

            Divider {}

            Rectangle {
                id: footer

                width: parent.width
                height: 28
                radius: Theme.radius.sm
                color: "transparent"

                Rectangle {
                    x: -Theme.panel.rowBleed
                    width: parent.width + Theme.panel.rowBleed * 2
                    height: parent.height
                    radius: parent.radius
                    color: footerHover.hovered ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.motion.fast
                        }
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Sound Settings…"
                    color: Theme.text.primary
                    font.family: Theme.font.ui
                    font.pixelSize: Theme.type.body.size
                }

                HoverHandler {
                    id: footerHover

                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: {
                        panel.close();
                        Quickshell.execDetached(["launch-or-focus-tui", "wiremix"]);
                    }
                }
            }
        }
    }

    component SoundGroup: Column {
        required property string label

        width: parent.width
        spacing: Theme.space.sm

        Text {
            text: parent.label
            color: Theme.text.secondary
            font.family: Theme.font.ui
            font.pixelSize: Theme.type.label.size
            font.weight: Font.DemiBold
        }
    }

    component DeviceRow: Item {
        id: row

        required property var modelData
        required property bool selected

        signal chosen

        width: parent.width
        height: 34

        Rectangle {
            x: -Theme.panel.rowBleed
            width: parent.width + Theme.panel.rowBleed * 2
            height: parent.height
            radius: Theme.radius.sm
            color: rowHover.hovered ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

            Behavior on color {
                ColorAnimation {
                    duration: Theme.motion.fast
                }
            }
        }

        Rectangle {
            id: badge

            anchors.verticalCenter: parent.verticalCenter
            width: 26
            height: 26
            radius: height / 2
            color: row.selected ? Theme.accent : Theme.fill.press

            Behavior on color {
                ColorAnimation {
                    duration: Theme.motion.fast
                }
            }

            Text {
                anchors.centerIn: parent
                text: AudioService.deviceIcon(row.modelData)
                color: row.selected ? Theme.accentText : Theme.text.primary
                font.family: Theme.font.iconFill
                font.pixelSize: Theme.icon.xs
            }
        }

        Text {
            anchors.left: badge.right
            anchors.leftMargin: Theme.space.md
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: AudioService.shortLabel(row.modelData)
            textFormat: Text.PlainText
            elide: Text.ElideRight
            color: Theme.text.primary
            font.family: Theme.font.ui
            font.pixelSize: Theme.type.body.size
        }

        HoverHandler {
            id: rowHover

            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: row.chosen()
        }
    }
}
