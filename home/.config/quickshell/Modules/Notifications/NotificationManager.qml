import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import qs.Constants
import qs.Services

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: notificationPanel

            focusable: false
            color: "transparent"

            mask: Region {
                item: notificationList
            }

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            WlrLayershell.namespace: "qs-notifications"
            WlrLayershell.margins.top: Theme.panelHeight

            exclusionMode: ExclusionMode.Ignore

            anchors {
                top: true
                right: true
            }

            implicitWidth: Theme.notifications.panelWidth
            implicitHeight: notificationList.displayHeight + Theme.panelHeight + Theme.notifications.margin

            ListView {
                id: notificationList

                readonly property int maxVisible: 5
                property real displayHeight: contentHeight

                onContentHeightChanged: {
                    if (contentHeight > displayHeight) {
                        displayHeight = contentHeight;
                    } else {
                        shrinkTimer.restart();
                    }
                }

                Timer {
                    id: shrinkTimer
                    interval: 220
                    repeat: false
                    onTriggered: displayHeight = contentHeight
                }

                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: Theme.notifications.margin
                anchors.rightMargin: Theme.notifications.margin

                width: Theme.notifications.cardWidth
                height: displayHeight
                spacing: Theme.notifications.spacing

                clip: false
                interactive: false

                add: Transition {
                    ParallelAnimation {
                        NumberAnimation {
                            property: "opacity"
                            from: 0
                            to: 1
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                        NumberAnimation {
                            property: "cardScale"
                            from: 0.96
                            to: 1.0
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                remove: Transition {
                    ParallelAnimation {
                        NumberAnimation {
                            property: "opacity"
                            to: 0
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                        NumberAnimation {
                            property: "cardScale"
                            to: 0.96
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                addDisplaced: Transition {
                    NumberAnimation {
                        property: "y"
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        property: "opacity"
                        to: 1
                        duration: 0
                    }
                    NumberAnimation {
                        property: "cardScale"
                        to: 1.0
                        duration: 0
                    }
                }

                removeDisplaced: Transition {
                    NumberAnimation {
                        property: "y"
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }

                model: ScriptModel {
                    values: NotificationService.notifications.slice(0, notificationList.maxVisible)
                    objectProp: "id"
                }

                delegate: Rectangle {
                    id: card

                    property var notification: modelData
                    property real cardScale: 1.0

                    width: ListView.view.width
                    height: cardContent.implicitHeight + 24

                    transform: Scale {
                        xScale: card.cardScale
                        yScale: card.cardScale
                        origin.x: card.width / 2
                        origin.y: card.height / 2
                    }

                    radius: 16
                    border.width: 1
                    color: Colors.surface_container
                    border.color: Colors.outline_variant

                    HoverHandler {
                        id: cardHover
                    }

                    ColumnLayout {
                        id: cardContent
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 12
                        anchors.topMargin: 12
                        anchors.bottomMargin: 12
                        spacing: 6

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Item {
                                Layout.preferredWidth: 16
                                Layout.preferredHeight: 16
                                Layout.alignment: Qt.AlignVCenter
                                visible: appIconImage.status === Image.Ready

                                IconImage {
                                    id: appIconImage
                                    anchors.centerIn: parent
                                    source: Quickshell.iconPath(card.notification.appIcon, true)
                                    implicitSize: 16
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: card.notification.appName
                                color: Colors.on_surface_variant
                                font.family: Fonts.font
                                font.pixelSize: Fonts.p
                                elide: Text.ElideRight
                            }

                            Text {
                                text: Icons.close
                                font.family: Fonts.iconFont
                                font.pixelSize: 16
                                color: Colors.on_surface_variant
                                opacity: cardHover.hovered ? 1 : 0

                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 150
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: NotificationService.removeNotification(notification.id)
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: card.notification.summary
                            visible: text !== ""
                            color: Colors.on_surface
                            font.family: Fonts.font
                            font.pixelSize: Fonts.h5
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            text: card.notification.body
                            visible: text !== ""
                            color: Colors.on_surface_variant
                            font.family: Fonts.font
                            font.pixelSize: Fonts.p
                            font.weight: Font.Normal
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            lineHeight: 1.2
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            visible: card.notification.actions.length > 0

                            Repeater {
                                model: card.notification.actions

                                Rectangle {
                                    required property var modelData

                                    Layout.preferredHeight: 28
                                    Layout.fillWidth: true
                                    color: Colors.surface_container_high
                                    radius: 6
                                    border.color: Colors.outline_variant
                                    border.width: 1

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.text
                                        color: Colors.on_surface
                                        font.family: Fonts.font
                                        font.pixelSize: Fonts.p
                                        elide: Text.ElideRight
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: modelData.invoke()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
