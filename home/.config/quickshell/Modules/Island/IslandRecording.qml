import QtQuick
import qs.Constants
import qs.Services

IslandPane {
    id: details

    pop: true
    implicitWidth: column.implicitWidth
    implicitHeight: column.implicitHeight

    Column {
        id: column

        spacing: Theme.space.xs

        Repeater {
            model: StreamingService.screenAccessApps

            Text {
                required property string modelData

                anchors.horizontalCenter: parent.horizontalCenter
                text: modelData
                color: Theme.text.secondary
                font.pixelSize: Theme.type.body.size
                font.family: Theme.font.ui
            }
        }

        Rectangle {
            visible: StreamingService.isRecordingScreen
            anchors.horizontalCenter: parent.horizontalCenter
            width: stopLabel.implicitWidth + Theme.island.stopPadding
            height: Theme.island.stopHeight
            radius: Theme.radius.control
            color: stopHover.hovered ? Theme.danger : "transparent"
            border.width: 1
            border.color: Theme.danger

            Text {
                id: stopLabel

                anchors.centerIn: parent
                text: "Stop"
                color: stopHover.hovered ? Theme.dangerText : Theme.danger
                font.pixelSize: Theme.type.body.size
                font.family: Theme.font.ui
                font.weight: Theme.type.title.weight
            }

            HoverHandler {
                id: stopHover

                cursorShape: Qt.PointingHandCursor
            }
            TapHandler {
                onTapped: StreamingService.stopRecording()
            }
        }
    }
}
