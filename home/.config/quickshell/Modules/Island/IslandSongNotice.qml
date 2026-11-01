import QtQuick
import QtQuick.Effects
import Quickshell.Widgets
import qs.Components
import qs.Constants
import qs.Services

Item {
    id: notice

    property bool shown: false
    property real radius: 0

    implicitHeight: pane.implicitHeight

    ClippingRectangle {
        anchors.fill: parent
        radius: notice.radius
        color: "transparent"
        opacity: notice.shown ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.motion.fast
            }
        }

        CrossfadeImage {
            id: backgroundArt

            anchors.fill: parent
            source: IslandService.trackArtUrl || ""
            duration: Theme.motion.slow
            layer.enabled: parent.opacity > 0
            layer.effect: MultiEffect {
                blurEnabled: true
                blurMax: Theme.island.noticeBlur
                blur: 1
            }
        }

        Rectangle {
            anchors.fill: parent
            color: Theme.withAlpha(Theme.shadow, 0.6)
            opacity: backgroundArt.ready ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.motion.slow
                    easing.type: Theme.motion.easeSmooth
                }
            }
        }
    }

    IslandPane {
        id: pane

        anchors.top: parent.top
        anchors.topMargin: Theme.island.inset
        anchors.horizontalCenter: parent.horizontalCenter
        width: Theme.island.noticeWidth - Theme.island.inset * 2
        implicitHeight: row.implicitHeight
        shown: notice.shown
        pop: true

        Row {
            id: row

            width: parent.width
            spacing: Theme.space.lg

            ClippingRectangle {
                id: artFrame

                width: Theme.row.tile
                height: Theme.row.tile
                radius: Theme.radius.control
                color: Theme.colors.raised

                Text {
                    anchors.centerIn: parent
                    text: PhosphorIcons.musicNoteSimple
                    font.family: Theme.font.icon
                    font.pixelSize: Theme.icon.lg
                    color: Theme.text.secondary
                    opacity: art.ready ? 0 : 1
                }

                CrossfadeImage {
                    id: art

                    anchors.fill: parent
                    tag: IslandService.track
                    source: tag?.artUrl ?? ""
                }
            }

            Column {
                id: textColumn

                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - artFrame.width - skip.width - parent.spacing * 2
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
                    font.pixelSize: Theme.type.body.size
                    font.family: Theme.font.ui
                    font.weight: Theme.type.title.weight
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                Text {
                    width: parent.width
                    visible: text !== ""
                    text: swap.shown.artist ?? ""
                    color: Theme.text.secondary
                    font.pixelSize: Theme.type.caption.size
                    font.family: Theme.font.ui
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }
            }

            MediaControlButton {
                id: skip

                anchors.verticalCenter: parent.verticalCenter
                icon: PhosphorIcons.fastForward
                onTapped: MediaControlService.next()
            }
        }
    }
}
