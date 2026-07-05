import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
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
            item: localNotifications.length > 0 ? cardColumn : null
        }

        WlrLayershell.namespace: "qs.notification_overlay"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.margins.top: Theme.topBarHeight
        WlrLayershell.margins.right: 5
        WlrLayershell.exclusionMode: ExclusionMode.Ignore

        visible: modelData.name === Theme.primaryMonitor && localNotifications.length > 0 && !Visibilities.notificationCenter

        anchors {
            top: true
            right: true
        }

        implicitWidth: Theme.notifications.panelWidth
        implicitHeight: cardColumn.implicitHeight + Theme.notifications.margin * 2

        property var localNotifications: []

        function removeLocal(id) {
            localNotifications = localNotifications.filter(n => n.id !== id);
        }

        Connections {
            target: NotificationService
            function onNotificationsChanged() {
                const svc = NotificationService.notifications.slice(0, 5);
                const localIds = new Set(notificationPanel.localNotifications.map(n => n.id));
                svc.forEach(n => {
                    if (n && !localIds.has(n.id))
                        notificationPanel.localNotifications = [...notificationPanel.localNotifications, n];
                });
            }
        }

        Column {
            id: cardColumn
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: Theme.notifications.margin
            anchors.rightMargin: Theme.notifications.margin
            width: Theme.notifications.cardWidth
            spacing: Theme.notifications.spacing

            HoverHandler {
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

            Repeater {
                model: ScriptModel {
                    values: notificationPanel.localNotifications
                    objectProp: "id"
                }

                delegate: Item {
                    id: delegateWrapper
                    required property var modelData

                    property bool leaving: false

                    width: cardColumn.width
                    height: leaving ? 0 : card.height
                    clip: true
                    opacity: leaving ? 0 : 1

                    Behavior on height {
                        NumberAnimation {
                            duration: Theme.animations.fast
                            easing.type: Easing.InCubic
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.animations.fast
                            easing.type: Easing.InCubic
                        }
                    }

                    Component.onCompleted: appearAnim.start()

                    NumberAnimation {
                        id: appearAnim
                        target: delegateWrapper
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: Theme.animations.slow
                        easing.type: Easing.OutCubic
                    }

                    Connections {
                        target: NotificationService
                        function onNotificationsChanged() {
                            const notif = delegateWrapper?.modelData;
                            if (!notif)
                                return;
                            const gone = !NotificationService.notifications.some(n => n?.id === notif.id);
                            if (gone && !delegateWrapper.leaving) {
                                delegateWrapper.leaving = true;
                                removeTimer.start();
                            }
                        }
                    }

                    Timer {
                        id: removeTimer
                        interval: Theme.animations.fast + 20
                        repeat: false
                        onTriggered: notificationPanel.removeLocal(delegateWrapper.modelData.id)
                    }

                    NotificationCard {
                        id: card
                        width: delegateWrapper.width
                        modelData: delegateWrapper.modelData
                    }
                }
            }
        }
    }
}
