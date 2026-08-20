import QtQuick
import qs.Constants
import qs.Services

// The notification centre's content, with no window of its own — a plain Item
// so it can sit in a popup or the island; the caller supplies the surface.
Item {
    id: root

    // Height budget; the list scrolls within whatever's left after the header.
    property int maxHeight: 0

    // Gutter for the cards' close badges to hang into.
    readonly property int gutter: 10

    implicitWidth: 332
    implicitHeight: stack.implicitHeight

    Column {
        id: stack
        width: parent.width
        spacing: 6

        Item {
            id: header
            x: root.gutter
            width: parent.width - root.gutter
            height: 28

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "Notification Center"
                color: Colors.on_surface
                font.family: Fonts.font
                font.pixelSize: Fonts.h4
                font.weight: Font.DemiBold
            }

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
                    text: Icons.deleteSweep
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
            x: root.gutter
            width: parent.width - root.gutter
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
