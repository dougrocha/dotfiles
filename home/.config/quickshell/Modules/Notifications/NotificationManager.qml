import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.Constants
import qs.Services

Variants {
    id: root
    model: Quickshell.screens

    delegate: PanelWindow {
        id: notificationPanel

        required property var modelData
        screen: modelData

        focusable: false
        color: "transparent"

        mask: Region {
            item: NotificationService.notifications.length > 0 ? notificationList : null
        }

        WlrLayershell.namespace: "qs.notification_overlay"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.margins.top: Theme.topBarHeight
        WlrLayershell.margins.right: 5
        WlrLayershell.exclusionMode: ExclusionMode.Ignore

        visible: {
            const isFocused = Hyprland.focusedMonitor && modelData.name === Hyprland.focusedMonitor.name;
            return isFocused && NotificationService.notifications.length > 0;
        }

        anchors {
            top: true
            right: true
        }

        implicitWidth: Theme.notifications.panelWidth
        implicitHeight: notificationList.displayHeight + Theme.topBarHeight + Theme.notifications.margin

        ListView {
            id: notificationList

            readonly property int maxVisible: 5
            readonly property int removeDuration: Theme.animations.normal
            property real displayHeight: 0

            onContentHeightChanged: {
                if (contentHeight > notificationList.displayHeight) {
                    heightBehavior.enabled = false;
                    notificationList.displayHeight = contentHeight;
                    heightBehavior.enabled = true;
                } else {
                    shrinkTimer.restart();
                }
            }

            Timer {
                id: shrinkTimer
                interval: notificationList.removeDuration
                repeat: false
                onTriggered: notificationList.displayHeight = notificationList.contentHeight
            }

            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: Theme.notifications.margin
            anchors.rightMargin: Theme.notifications.margin

            width: Theme.notifications.cardWidth
            height: displayHeight
            spacing: Theme.notifications.spacing

            Behavior on displayHeight {
                id: heightBehavior
                NumberAnimation {
                    duration: Theme.animations.slow
                    easing.type: Easing.OutCubic
                }
            }

            clip: false
            interactive: false

            HoverHandler {
                id: listHover
                onHoveredChanged: {
                    if (hovered) {
                        unhoverTimer.stop();
                        NotificationService.stackPaused = true;
                    } else {
                        unhoverTimer.restart();
                    }
                }
            }

            Timer {
                id: unhoverTimer
                interval: 100
                repeat: false
                onTriggered: NotificationService.stackPaused = false
            }

            add: Transition {
                ParallelAnimation {
                    NumberAnimation {
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: notificationList.removeDuration
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        property: "x"
                        from: 40
                        to: 0
                        duration: notificationList.removeDuration
                        easing.type: Easing.OutCubic
                    }
                }
            }

            remove: Transition {
                ParallelAnimation {
                    NumberAnimation {
                        property: "opacity"
                        to: 0
                        duration: notificationList.removeDuration
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        property: "x"
                        to: 40
                        duration: notificationList.removeDuration
                        easing.type: Easing.OutCubic
                    }
                }
            }

            displaced: Transition {
                NumberAnimation {
                    property: "y"
                    duration: Theme.animations.slow
                    easing.type: Easing.OutCubic
                }
            }

            model: ScriptModel {
                values: NotificationService.notifications.slice(0, notificationList.maxVisible)
                objectProp: "id"
            }

            delegate: NotificationCard {
                width: ListView.view.width
            }
        }
    }
}
