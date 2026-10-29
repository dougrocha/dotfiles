pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Components
import qs.Constants
import qs.Services

Variants {
    id: root
    model: Theme.primaryScreens

    delegate: PanelWindow {
        id: notificationPanel

        required property var modelData
        screen: modelData

        focusable: false
        color: "transparent"

        mask: Region {
            item: NotificationService.popups.length > 0 ? cardColumn : null
        }

        WlrLayershell.namespace: "qs.notification_overlay"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.margins.top: Theme.topBarHeight
        WlrLayershell.margins.right: 5
        WlrLayershell.exclusionMode: ExclusionMode.Ignore

        visible: NotificationService.popups.length > 0 && !Visibilities.isOpen(Visibilities.names.notifications)

        anchors {
            top: true
            right: true
        }

        implicitWidth: 384

        implicitHeight: Math.max(1, modelData.height - Theme.topBarHeight)

        Column {
            id: cardColumn
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: Theme.space.lg
            anchors.rightMargin: Theme.space.lg
            width: 372
            spacing: Theme.space.sm

            HoverHandler {
                onHoveredChanged: {
                    if (hovered) {
                        unhoverTimer.stop();
                        NotificationService.pause();
                    } else {
                        unhoverTimer.restart();
                    }
                }
            }

            Timer {
                id: unhoverTimer
                interval: 100
                onTriggered: NotificationService.resume()
            }

            Repeater {
                model: ScriptModel {
                    values: NotificationService.popups
                    objectProp: "id"
                }

                delegate: Item {
                    id: delegateWrapper
                    required property var modelData

                    readonly property bool leaving: modelData?.leaving === true
                    property bool entered: false

                    readonly property int badgeInset: Theme.space.lg

                    width: cardColumn.width
                    height: leaving || !entered ? 0 : card.height + badgeInset
                    clip: true
                    opacity: leaving ? 0 : 1

                    SizeMotion on height {}

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.motion.fast
                            easing.type: Theme.motion.easeExit
                        }
                    }

                    Component.onCompleted: {
                        entered = true;
                        appearAnim.start();
                    }

                    NumberAnimation {
                        id: appearAnim
                        target: delegateWrapper
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: Theme.motion.normal
                        easing.type: Theme.motion.easeStandard
                    }

                    NotificationCard {
                        id: card
                        x: delegateWrapper.badgeInset
                        y: delegateWrapper.badgeInset
                        width: delegateWrapper.width - delegateWrapper.badgeInset
                        modelData: delegateWrapper.modelData
                        enabled: !delegateWrapper.leaving
                    }
                }
            }

            Item {
                width: cardColumn.width
                height: presence.mapped ? morePill.height + Theme.space.sm : 0
                visible: presence.mapped

                SizeMotion on height {}

                Presence {
                    id: presence

                    active: NotificationService.queuedCount > 0
                }

                Rectangle {
                    id: morePill

                    anchors.right: parent.right
                    y: Theme.space.sm
                    width: moreLabel.implicitWidth + Theme.space.lg * 2
                    height: moreLabel.implicitHeight + Theme.space.xs * 2
                    radius: height / 2
                    color: Theme.colors.surface
                    border.width: 1
                    border.color: Theme.stroke.hairline
                    opacity: presence.progress
                    scale: presence.scale
                    transformOrigin: Item.Top

                    Text {
                        id: moreLabel

                        anchors.centerIn: parent
                        text: NotificationService.queuedCount + " more"
                        color: Theme.text.secondary
                        font.family: Theme.font.ui
                        font.pixelSize: Theme.type.caption.size
                    }
                }
            }
        }
    }
}
