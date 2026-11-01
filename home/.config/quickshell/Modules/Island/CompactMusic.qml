import QtQuick
import qs.Constants
import qs.Services

IslandPane {
    id: pane

    property bool revealed: true

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Row {
        id: row

        spacing: Theme.space.md

        Item {
            id: clip

            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(label.implicitWidth, Theme.island.titleMaxWidth)
            height: label.implicitHeight
            clip: true

            Text {
                id: label

                readonly property real overflow: Math.max(0, implicitWidth - clip.width)
                readonly property bool scrolling: label.overflow > 0 && clip.visible && pane.revealed

                text: MprisService.nowPlaying(IslandService.trackTitle, IslandService.trackArtist)
                color: Theme.text.primary
                font.pixelSize: Theme.type.body.size
                font.family: Theme.font.ui
                font.weight: Theme.type.title.weight

                onTextChanged: x = 0
                onScrollingChanged: if (!label.scrolling)
                    x = 0

                SequentialAnimation on x {
                    running: label.scrolling
                    loops: Animation.Infinite
                    PauseAnimation {
                        duration: Theme.motion.marqueePause
                    }
                    NumberAnimation {
                        from: 0
                        to: -label.overflow
                        duration: label.overflow * 40
                        easing.type: Theme.motion.easeSmooth
                    }
                    PauseAnimation {
                        duration: Theme.motion.marqueePause
                    }
                    NumberAnimation {
                        from: -label.overflow
                        to: 0
                        duration: label.overflow * 40
                        easing.type: Theme.motion.easeSmooth
                    }
                }
            }

            HoverHandler {
                cursorShape: Qt.PointingHandCursor
            }
        }
    }
}
