import QtQuick
import qs.Constants
import qs.Services

IslandPane {
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Row {
        id: row

        spacing: Theme.space.md

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: {
                if (IslandService.osdMode === "mic")
                    return IslandService.osdMuted ? PhosphorIcons.microphoneSlash : PhosphorIcons.microphone;
                return AudioService.speakerGlyph(IslandService.osdLevel, IslandService.osdMuted);
            }
            color: IslandService.osdMuted ? Theme.text.secondary : Theme.text.primary
            font.pixelSize: Theme.icon.md
            font.family: Theme.font.icon
        }

        ProgressTrack {
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.island.osdTrackWidth
            fraction: Math.min(IslandService.osdLevel, 1)
            fillColor: IslandService.osdMuted ? Theme.text.tertiary : Theme.text.primary
            fillDuration: Theme.motion.instant
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: IslandService.osdLabel !== "" ? IslandService.osdLabel : Math.round(IslandService.osdLevel * 100) + "%"
            color: Theme.text.primary
            font.pixelSize: Theme.type.body.size
            font.family: Theme.font.ui
        }
    }
}
