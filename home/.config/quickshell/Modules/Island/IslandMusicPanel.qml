import QtQuick
import QtQuick.Effects
import Quickshell.Widgets
import qs.Components
import qs.Constants
import qs.Services

IslandPane {
    id: panel

    function formatTime(seconds) {
        if (!seconds || seconds < 0)
            return "0:00";
        const mins = Math.floor(seconds / 60);
        const secs = Math.floor(seconds % 60);
        return mins + ":" + (secs < 10 ? "0" : "") + secs;
    }

    pop: true
    implicitWidth: Theme.island.panelWidth
    implicitHeight: body.height

    Item {
        id: body

        width: parent.width
        height: IslandService.musicAvailable ? player.height : empty.height

        SizeMotion on height {}

        Column {
            id: player

            width: parent.width
            opacity: IslandService.musicAvailable ? 1 : 0
            visible: opacity > 0
            spacing: Theme.space.lg

            Row {
                width: parent.width
                spacing: Theme.space.lg

                Item {
                    width: Theme.island.artSize
                    height: Theme.island.artSize
                    scale: IslandService.isPlaying ? 1 : Theme.motion.scaleFrom
                    opacity: IslandService.isPlaying ? 1 : 0.7

                    Behavior on scale {
                        NumberAnimation {
                            duration: Theme.motion.normal
                            easing.type: Theme.motion.easeStandard
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.motion.normal
                        }
                    }

                    CrossfadeImage {
                        anchors.centerIn: parent
                        width: parent.width * 1.2
                        height: parent.height * 1.2
                        tag: IslandService.track
                        source: tag?.artUrl ?? ""
                        opacity: IslandService.isPlaying ? 0.55 : 0
                        layer.enabled: panel.visible && opacity > 0
                        layer.effect: MultiEffect {
                            blurEnabled: true
                            blurMax: Theme.island.glowBlur
                            blur: 1
                        }

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Theme.motion.slow
                            }
                        }
                    }

                    ClippingRectangle {
                        anchors.fill: parent
                        radius: Theme.radius.control
                        color: Theme.colors.raised

                        Text {
                            anchors.centerIn: parent
                            text: PhosphorIcons.musicNoteSimple
                            font.family: Theme.font.icon
                            font.pixelSize: Theme.icon.xl
                            color: Theme.text.tertiary
                            opacity: art.ready ? 0 : 1
                        }

                        CrossfadeImage {
                            id: art

                            anchors.fill: parent
                            tag: IslandService.track
                            source: tag?.artUrl ?? ""
                        }
                    }
                }

                Column {
                    id: textColumn

                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - Theme.island.artSize - Theme.space.lg
                    spacing: Theme.space.xxs
                    transform: Translate {
                        y: swap.offset
                    }

                    TrackSwap {
                        id: swap

                        target: textColumn
                        source: art.shownTag ?? IslandService.track
                    }

                    Text {
                        width: parent.width
                        text: swap.shown.title ?? ""
                        color: Theme.text.primary
                        font.pixelSize: Theme.type.heading.size
                        font.family: Theme.font.ui
                        font.weight: Theme.type.heading.weight
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    Text {
                        width: parent.width
                        visible: text !== ""
                        text: swap.shown.artist ?? ""
                        color: Theme.text.secondary
                        font.pixelSize: Theme.type.body.size
                        font.family: Theme.font.ui
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }
                }
            }

            Item {
                width: parent.width
                height: Theme.row.badge

                Timer {
                    id: seekDebounce

                    interval: 300
                }

                Text {
                    id: elapsedLabel

                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: remainingLabel.implicitWidth
                    text: panel.formatTime(seekSlider.value)
                    color: Theme.text.tertiary
                    font.pixelSize: Theme.type.caption.size
                    font.family: Theme.font.ui
                    font.features: ({
                            "tnum": 1
                        })
                }

                StyledSlider {
                    id: seekSlider

                    anchors.left: elapsedLabel.right
                    anchors.right: remainingLabel.left
                    anchors.leftMargin: Theme.space.md
                    anchors.rightMargin: Theme.space.md
                    anchors.verticalCenter: parent.verticalCenter
                    from: 0
                    to: IslandService.duration > 0 ? IslandService.duration : 1
                    boundValue: IslandService.position
                    enabled: IslandService.canSeek

                    holding: seekDebounce.running
                    trackColor: Theme.fill.strong
                    handleSize: 0
                    onPressedChanged: {
                        if (!pressed) {
                            MediaControlService.seek(value);
                            seekDebounce.start();
                        }
                    }
                }

                Text {
                    id: remainingLabel

                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    text: "-" + panel.formatTime(Math.max(0, IslandService.duration - seekSlider.value))
                    color: Theme.text.tertiary
                    font.pixelSize: Theme.type.caption.size
                    font.family: Theme.font.ui
                    font.features: ({
                            "tnum": 1
                        })
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.space.xl

                MediaControlButton {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: PhosphorIcons.rewind
                    iconSize: Theme.icon.lg
                    onTapped: MediaControlService.previous()
                }

                MediaControlButton {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: IslandService.isPlaying ? PhosphorIcons.pause : PhosphorIcons.play
                    iconSize: Theme.icon.xl
                    onTapped: MediaControlService.playpause()
                }

                MediaControlButton {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: PhosphorIcons.fastForward
                    iconSize: Theme.icon.lg
                    onTapped: MediaControlService.next()
                }
            }
        }

        Item {
            id: empty

            width: parent.width
            height: player.implicitHeight
            opacity: IslandService.musicAvailable ? 0 : 1
            visible: opacity > 0

            Column {
                anchors.centerIn: parent
                spacing: Theme.space.md

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: PhosphorIcons.musicNoteSimple
                    color: Theme.text.secondary
                    font.pixelSize: Theme.icon.xxl
                    font.family: Theme.font.icon
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Nothing playing"
                    color: Theme.text.secondary
                    font.pixelSize: Theme.type.body.size
                    font.family: Theme.font.ui
                }
            }
        }
    }
}
