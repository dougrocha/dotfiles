import QtQuick
import Quickshell.Widgets
import qs.Components
import qs.Constants
import qs.Services

Rectangle {
    id: bubble

    property string kind: ""
    property bool revealed: true

    readonly property bool shown: kind !== "" && revealed
    property string shownKind: kind

    onKindChanged: if (kind !== "")
        shownKind = kind

    width: Theme.island.compactHeight
    height: Theme.island.compactHeight
    radius: height / 2
    color: Theme.colors.surface
    opacity: shown ? 1 : 0
    scale: shown ? 1 : Theme.motion.scaleFrom
    visible: opacity > 0

    ContentFade on opacity {}

    SpringMotion on scale {
        epsilon: 0.005
    }

    ClippingRectangle {
        anchors.fill: parent
        anchors.margins: Theme.space.xs
        radius: height / 2
        color: "transparent"
        visible: bubble.shownKind === "music" && IslandService.trackArtUrl !== ""

        CrossfadeImage {
            anchors.fill: parent
            source: IslandService.trackArtUrl || ""
        }
    }

    Text {
        anchors.centerIn: parent
        visible: bubble.shownKind === "music" && IslandService.trackArtUrl === ""
        text: PhosphorIcons.musicNoteSimple
        color: Theme.text.secondary
        font.family: Theme.font.icon
        font.pixelSize: Theme.icon.xs
    }

    Text {
        anchors.centerIn: parent
        visible: bubble.shownKind === "alert"
        text: IslandService.currentAlert?.glyph ?? ""
        color: Theme.accent
        font.family: Theme.font.icon
        font.pixelSize: Theme.icon.xs
    }

    RecordingDot {
        anchors.centerIn: parent
        visible: bubble.shownKind === "recording"
        pulsing: bubble.visible && bubble.shownKind === "recording"
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }
    TapHandler {
        onTapped: IslandService.bubbleTapped(bubble.shownKind)
    }
}
