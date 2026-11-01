import QtQuick
import qs.Components
import qs.Constants
import qs.Services

Item {
    id: root

    readonly property bool hasHistory: NotificationService.history.length > 0

    readonly property int bleed: Theme.panel.rowBleed

    implicitHeight: stack.implicitHeight

    function reset(): void {
        calendar.reset();
    }

    Column {
        id: stack
        width: parent.width
        spacing: Theme.space.lg

        CalendarView {
            id: calendar
            width: parent.width
        }

        Divider {
            bleed: root.bleed
        }

        Item {
            id: header
            width: parent.width
            height: 22

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "Notifications"
                color: Theme.text.primary
                font.family: Theme.font.ui
                font.pixelSize: Theme.type.title.size
                font.weight: Theme.type.title.weight
            }

            TextLink {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: root.hasHistory
                text: "Clear all"
                onTapped: NotificationService.clearHistory()
            }
        }

        Item {
            width: parent.width
            height: 72
            visible: !root.hasHistory

            Text {
                anchors.centerIn: parent
                text: "No notifications"
                color: Theme.text.tertiary
                font.family: Theme.font.ui
                font.pixelSize: Theme.type.body.size
            }
        }

        PanelScroll {
            visible: root.hasHistory

            NotificationHistory {
                width: parent.width
                bleed: root.bleed
            }
        }
    }
}
