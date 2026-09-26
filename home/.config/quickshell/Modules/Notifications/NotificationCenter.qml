import QtQuick
import qs.Components
import qs.Constants
import qs.Modules.Popups
import qs.Services

Item {
    id: root

    property int maxHeight: 0

    readonly property bool hasHistory: NotificationService.history.length > 0

    readonly property int bleed: Theme.space.sm

    implicitHeight: stack.implicitHeight

    Connections {
        target: Visibilities
        function onNotificationCenterChanged() {
            if (Visibilities.notificationCenter)
                calendar.reset();
        }
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

            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: root.hasHistory
                text: "Clear all"
                color: clearAllHover.hovered ? Theme.text.primary : Theme.text.secondary
                font.family: Theme.font.ui
                font.pixelSize: Theme.type.label.size
                font.weight: Theme.type.label.weight

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.motion.fast
                    }
                }

                HoverHandler {
                    id: clearAllHover
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: NotificationService.clearHistory()
                }
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

        Flickable {
            id: historyScroll
            x: -root.bleed
            width: parent.width + root.bleed * 2
            visible: root.hasHistory
            height: root.maxHeight > 0 ? Math.min(history.implicitHeight, root.maxHeight - calendar.height - header.height - Theme.space.lg * 4 - 1) : history.implicitHeight
            contentHeight: history.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            interactive: contentHeight > height

            NotificationHistory {
                id: history
                x: root.bleed
                width: historyScroll.width - root.bleed * 2
                bleed: root.bleed
            }
        }
    }
}
