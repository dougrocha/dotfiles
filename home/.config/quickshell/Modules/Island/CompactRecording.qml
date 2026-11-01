import QtQuick
import qs.Constants
import qs.Services

IslandPane {
    id: pane

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Row {
        id: row

        spacing: Theme.space.md

        RecordingDot {
            anchors.verticalCenter: parent.verticalCenter
            pulsing: pane.shown

            TapHandler {
                onTapped: IslandService.toggleRecordingDetails()
            }
            HoverHandler {
                cursorShape: Qt.PointingHandCursor
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: StreamingService.isRecordingScreen ? "Recording" : "Screen shared"
            color: Theme.danger
            font.pixelSize: Theme.type.body.size
            font.family: Theme.font.ui
            font.weight: Theme.type.title.weight

            TapHandler {
                onTapped: IslandService.toggleRecordingDetails()
            }
            HoverHandler {
                cursorShape: Qt.PointingHandCursor
            }
        }
    }
}
