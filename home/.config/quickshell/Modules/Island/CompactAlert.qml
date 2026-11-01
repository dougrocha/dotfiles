import QtQuick
import qs.Constants
import qs.Services

IslandPane {
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Row {
        id: row

        spacing: Theme.space.sm

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: text !== ""
            text: IslandService.currentAlert?.glyph ?? ""
            color: Theme.accent
            font.pixelSize: Theme.icon.md
            font.family: Theme.font.icon
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(implicitWidth, Theme.island.alertTextMaxWidth)
            text: IslandService.currentAlert?.text ?? ""
            color: Theme.text.primary
            font.pixelSize: Theme.type.body.size
            font.family: Theme.font.ui
            elide: Text.ElideRight
        }

        ProgressTrack {
            anchors.verticalCenter: parent.verticalCenter
            visible: (IslandService.currentAlert?.progress ?? -1) >= 0
            width: Theme.island.alertTrackWidth
            fraction: Math.max(0, IslandService.currentAlert?.progress ?? 0)
        }
    }
}
