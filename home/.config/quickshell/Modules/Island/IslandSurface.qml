pragma ComponentBehavior: Bound

import QtQuick
import qs.Components
import qs.Constants
import qs.Services

Item {
    id: surface

    property bool revealed: true
    property string mode: IslandService.mode
    property string activity: IslandService.activity
    property string secondaryActivity: IslandService.secondaryActivity
    readonly property Item pillItem: pill
    readonly property Item bubbleItem: bubble

    readonly property bool musicMode: mode === IslandService.modes.music
    readonly property bool songMode: mode === IslandService.modes.song
    readonly property bool recordingMode: mode === IslandService.modes.recording

    implicitWidth: pill.width
    implicitHeight: pill.y + pill.height

    Rectangle {
        id: pill

        property real cornerRadius: surface.musicMode ? Theme.radius.island : surface.songMode ? Theme.radius.surface : surface.recordingMode ? Theme.radius.hud : Theme.island.compactHeight / 2

        SpringMotion on cornerRadius {}

        anchors.horizontalCenter: parent.horizontalCenter
        y: Theme.island.top

        width: surface.musicMode ? panel.implicitWidth + Theme.island.inset * 2 : surface.songMode ? Theme.island.noticeWidth : compact.implicitWidth + Theme.island.compactPadding
        height: surface.musicMode ? panel.implicitHeight + Theme.island.inset * 2 : surface.songMode ? notice.implicitHeight + Theme.island.inset * 2 : surface.recordingMode ? Theme.island.compactHeight + details.implicitHeight + Theme.island.detailsPadding : Theme.island.compactHeight
        radius: Math.min(height / 2, cornerRadius)
        color: surface.musicMode ? Theme.colors.bg : Theme.colors.surface
        clip: true

        SpringMotion on width {}
        SpringMotion on height {}

        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler {
            onTapped: IslandService.pillTapped(surface.mode, surface.activity)
        }

        IslandSongNotice {
            id: notice

            anchors.fill: parent
            shown: surface.songMode
            radius: pill.radius
        }

        IslandCompact {
            id: compact

            anchors.horizontalCenter: parent.horizontalCenter
            y: (Theme.island.compactHeight - height) / 2
            shown: !surface.musicMode && !surface.songMode
            activity: surface.activity
            revealed: surface.revealed
        }

        IslandRecording {
            id: details

            anchors.top: parent.top
            anchors.topMargin: Theme.island.compactHeight
            anchors.horizontalCenter: parent.horizontalCenter
            shown: surface.recordingMode
        }

        IslandMusicPanel {
            id: panel

            anchors.top: parent.top
            anchors.topMargin: Theme.island.inset
            anchors.horizontalCenter: parent.horizontalCenter
            shown: surface.musicMode
        }
    }

    IslandBubble {
        id: bubble

        x: pill.x + pill.width + Theme.space.sm
        y: pill.y
        kind: IslandService.bubbleKind(surface.mode, surface.activity, surface.secondaryActivity)
        revealed: surface.revealed
    }
}
