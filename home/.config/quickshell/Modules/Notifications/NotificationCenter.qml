import QtQuick
import QtQuick.Effects
import qs.Components
import qs.Constants
import qs.Services

Item {
    id: root

    property int maxHeight: 0

    readonly property bool hasHistory: NotificationService.history.length > 0

    readonly property int badgeOverhang: Theme.space.sm

    property bool menuOpen: false

    onHasHistoryChanged: {
        if (!hasHistory)
            menuOpen = false;
    }

    implicitHeight: stack.implicitHeight

    HoverHandler {
        id: panelHover
    }

    Item {
        anchors.fill: parent
        visible: root.menuOpen
        z: 9

        TapHandler {
            onTapped: root.menuOpen = false
        }
    }

    Column {
        id: stack
        width: parent.width
        spacing: 0

        Item {
            id: overflowSlot
            width: parent.width
            height: 22
            z: 10

            IconActionButton {
                id: overflowButton
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                size: 22
                circular: true
                glyph: PhosphorIcons.dotsThree
                visible: root.hasHistory
                opacity: panelHover.hovered || root.menuOpen ? 1 : 0
                enabled: opacity > 0
                onTapped: root.menuOpen = !root.menuOpen

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.motion.fast
                    }
                }
            }

            Rectangle {
                id: overflowMenu

                anchors.right: parent.right
                anchors.top: overflowButton.bottom
                anchors.topMargin: Theme.space.xs

                visible: root.menuOpen && root.hasHistory
                opacity: visible ? 1 : 0
                width: clearAllLabel.implicitWidth + Theme.space.lg * 2
                height: 32

                radius: Theme.radius.md
                color: Theme.colors.raised
                border.width: 1
                border.color: Theme.stroke.hairline

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: Qt.rgba(0, 0, 0, 0.45)
                    shadowBlur: 0.6
                    shadowVerticalOffset: 2
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.motion.fast
                    }
                }

                Text {
                    id: clearAllLabel

                    anchors.centerIn: parent
                    text: "Clear all"
                    color: clearAllHover.hovered ? Theme.danger : Theme.text.primary
                    font.family: Theme.font.ui
                    font.pixelSize: Theme.type.body.size

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.motion.fast
                        }
                    }
                }

                HoverHandler {
                    id: clearAllHover
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: {
                        NotificationService.clearHistory();
                        root.menuOpen = false;
                    }
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
                color: Theme.text.secondary
                font.family: Theme.font.ui
                font.pixelSize: Theme.type.body.size
            }
        }

        Flickable {
            id: historyScroll
            x: -root.badgeOverhang
            width: parent.width + root.badgeOverhang * 2
            visible: root.hasHistory
            height: root.maxHeight > 0 ? Math.min(history.implicitHeight, root.maxHeight - overflowSlot.height - stack.spacing) : history.implicitHeight
            contentHeight: history.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            interactive: contentHeight > height

            NotificationHistory {
                id: history
                x: root.badgeOverhang
                width: historyScroll.width - root.badgeOverhang * 2
                badgeOverhang: root.badgeOverhang
            }
        }
    }
}
