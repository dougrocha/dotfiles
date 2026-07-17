import QtQuick
import Quickshell
import qs.Components
import qs.Constants
import qs.Modules.Notifications
import qs.Services

PopupWindow {
    id: panel

    color: "transparent"

    implicitWidth: container.width
    implicitHeight: {
        const win = anchor.window;
        return (win && win.screen) ? Math.max(400, win.screen.height - win.height - 12) : 800;
    }

    mask: Region {
        item: container
    }

    visible: Visibilities.notificationCenter

    PopupGrab {
        popup: panel
        onDismissed: Visibilities.notificationCenter = false
    }

    onVisibleChanged: {
        Visibilities.notificationCenter = visible;
        if (visible)
            calendarView.reset();
    }

    Item {
        id: container

        property real reveal: Visibilities.notificationCenter ? 1 : 0
        Behavior on reveal {
            NumberAnimation {
                duration: Visibilities.notificationCenter ? 160 : 120
                easing.type: Visibilities.notificationCenter ? Easing.OutCubic : Easing.InCubic
            }
        }

        // 10px wider than the content column: a left gutter the cards' close
        // badges hang into, so card surfaces still align with the calendar.
        width: 332
        height: stack.implicitHeight
        opacity: reveal
        transform: Translate {
            y: (1 - container.reveal) * -6
        }

        focus: Visibilities.notificationCenter
        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Escape) {
                Visibilities.notificationCenter = false;
                event.accepted = true;
            }
        }

        Column {
            id: stack
            width: parent.width
            spacing: 6

            Item {
                id: header
                x: 10
                width: parent.width - 10
                height: 28

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Notification Center"
                    color: Colors.on_surface
                    font.family: Fonts.font
                    font.pixelSize: Fonts.p
                    font.weight: Font.DemiBold
                }

                // Clears the entire notification history.
                Rectangle {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: 24
                    height: 24
                    radius: Theme.blockRadius
                    color: headerClearHover.hovered ? Colors.surface_container_high : Colors.surface_container
                    border.width: 1
                    border.color: headerClearHover.hovered ? Colors.primary : Colors.outline_variant

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.animations.fast
                        }
                    }
                    Behavior on border.color {
                        ColorAnimation {
                            duration: Theme.animations.fast
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: Icons.close
                        color: headerClearHover.hovered ? Colors.primary : Colors.on_surface_variant
                        font.family: Fonts.iconFont
                        font.pixelSize: 14

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.animations.fast
                            }
                        }
                    }

                    HoverHandler {
                        id: headerClearHover
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        onTapped: NotificationService.clearHistory()
                    }
                }
            }

            Item {
                x: 10
                width: parent.width - 10
                height: 90
                visible: NotificationService.history.length === 0

                Text {
                    anchors.centerIn: parent
                    text: "No Notifications"
                    color: Colors.on_surface_variant
                    font.family: Fonts.font
                    font.pixelSize: Fonts.p
                }
            }

            Flickable {
                id: historyScroll
                width: parent.width
                visible: history.implicitHeight > 0
                height: Math.min(history.implicitHeight, panel.implicitHeight - header.height - calendarBlock.height - stack.spacing * 2)
                contentHeight: history.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                NotificationHistory {
                    id: history
                    width: historyScroll.width
                }
            }

            Rectangle {
                id: calendarBlock
                x: 10
                width: parent.width - 10
                height: calendarView.implicitHeight + 32
                radius: 12
                color: Colors.surface_container
                border.width: 1
                border.color: Colors.outline_variant
                clip: true

                Behavior on height {
                    NumberAnimation {
                        duration: Theme.animations.normal
                        easing.type: Easing.OutCubic
                    }
                }

                CalendarView {
                    id: calendarView
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: 16
                    }
                }
            }
        }
    }
}
