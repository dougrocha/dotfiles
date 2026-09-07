import QtQuick
import qs.Components
import qs.Constants
import qs.Services

Item {
    id: root

    property int maxHeight: 0

    readonly property int gutter: 10

    implicitWidth: 332
    implicitHeight: stack.implicitHeight

    Column {
        id: stack
        width: parent.width
        spacing: Theme.space.sm

        Item {
            id: header
            x: root.gutter
            width: parent.width - root.gutter
            height: 28

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "Notification Center"
                color: Theme.text.primary
                font.family: Theme.font.ui
                font.pixelSize: Theme.type.display.size
                font.weight: Theme.type.display.weight
            }

            IconActionButton {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                glyph: PhosphorIcons.broom
                bordered: true
                danger: true
                onTapped: NotificationService.clearHistory()
            }
        }

        Item {
            x: root.gutter
            width: parent.width - root.gutter
            height: 90
            visible: NotificationService.history.length === 0

            Text {
                anchors.centerIn: parent
                text: "No Notifications"
                color: Theme.text.secondary
                font.family: Theme.font.ui
                font.pixelSize: Theme.type.body.size
            }
        }

        Flickable {
            id: historyScroll
            width: parent.width
            visible: history.implicitHeight > 0
            height: root.maxHeight > 0 ? Math.min(history.implicitHeight, root.maxHeight - header.height - stack.spacing) : history.implicitHeight
            contentHeight: history.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            NotificationHistory {
                id: history
                width: historyScroll.width
            }
        }
    }
}
