pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Constants
import qs.Services

Item {
    id: card

    required property var modelData
    // History entries show their age; live popups are always "now".
    property bool showTimestamp: false
    // In a collapsed stack, a click expands the group instead of acting on the card.
    property bool interactive: true

    readonly property bool isCritical: modelData?.urgency === NotificationUrgency.Critical

    // Room for the close badge to straddle the corner; containers offset so the surface stays aligned.
    readonly property int overhang: 10

    height: surface.height + overhang

    function relativeTime(timestamp) {
        const mins = Math.floor((Date.now() - timestamp) / 60000);
        if (mins < 1)
            return "now";
        if (mins < 60)
            return mins + "m";
        const hours = Math.floor(mins / 60);
        if (hours < 24)
            return hours + "h";
        return Math.floor(hours / 24) + "d";
    }

    function defaultAction() {
        for (let i = 0; i < (card.modelData?.actions?.length ?? 0); i++) {
            const a = card.modelData.actions[i];
            if (a.identifier === "default") {
                a.invoke();
                return true;
            }
        }
        return false;
    }

    property bool actionHovered: false

    component ActionButton: Rectangle {
        required property var modelData

        Layout.preferredHeight: 28
        Layout.fillWidth: true
        radius: Theme.blockRadius
        color: actionHover.hovered ? Colors.surface_container_high : Colors.surface_container
        border.color: actionHover.hovered ? Colors.primary : Colors.outline_variant
        border.width: 1

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
            anchors.margins: 4
            text: modelData.text
            color: actionHover.hovered ? Colors.primary : Colors.on_surface_variant
            elide: Text.ElideRight
            font.family: Fonts.font
            font.pixelSize: Fonts.small
            Behavior on color {
                ColorAnimation {
                    duration: Theme.animations.fast
                }
            }
        }

        HoverHandler {
            id: actionHover
            cursorShape: Qt.PointingHandCursor
            onHoveredChanged: card.actionHovered = hovered
        }

        TapHandler {
            onTapped: modelData.invoke()
        }
    }

    Rectangle {
        id: surface

        x: card.overhang
        y: card.overhang
        width: card.width - card.overhang
        height: cardContent.implicitHeight + 12 * 2

        radius: 12
        border.width: 1
        color: Colors.surface_container
        // Critical cards never expire, so make that look deliberate.
        border.color: card.isCritical ? Colors.error : Colors.outline_variant

        HoverHandler {
            id: cardHover
        }

        TapHandler {
            enabled: card.interactive
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onTapped: function (eventPoint, button) {
                if (closeHover.hovered || card.actionHovered)
                    return;
                if (button === Qt.RightButton) {
                    NotificationService.removeNotification(card.modelData.id);
                    return;
                }
                if (!card.defaultAction()) {
                    NotificationService.removeNotification(card.modelData.id);
                }
            }
        }

        ColumnLayout {
            id: cardContent
            anchors.fill: parent
            anchors.margins: 12
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
                        source: Quickshell.iconPath(card.modelData?.appIcon ?? "", true)
                        implicitSize: 16
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: card.modelData?.appName ?? ""
                    color: Colors.on_surface_variant
                    font.family: Fonts.font
                    font.pixelSize: Fonts.small
                    elide: Text.ElideRight
                }

                Text {
                    visible: card.showTimestamp
                    text: card.relativeTime(card.modelData?.timestamp ?? Date.now())
                    color: Colors.on_surface_variant
                    font.family: Fonts.font
                    font.pixelSize: Fonts.small
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        Layout.fillWidth: true
                        text: card.modelData?.summary ?? ""
                        visible: text !== ""
                        color: Colors.on_surface
                        font.family: Fonts.font
                        font.pixelSize: Fonts.p
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: card.modelData?.body ?? ""
                        visible: text !== ""
                        color: Colors.on_surface_variant
                        font.family: Fonts.font
                        font.pixelSize: Fonts.small
                        font.weight: Font.Normal
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }
                }

                ClippingRectangle {
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 48
                    Layout.alignment: Qt.AlignTop
                    radius: 8
                    color: "transparent"
                    visible: notifImage.status === Image.Ready

                    Image {
                        id: notifImage
                        anchors.fill: parent
                        source: card.modelData?.image ?? ""
                        fillMode: Image.PreserveAspectCrop
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                visible: (card.modelData?.actions ?? []).filter(a => a.identifier !== "default" && a.text !== "").length > 0

                Repeater {
                    model: (card.modelData?.actions ?? []).filter(a => a.identifier !== "default" && a.text !== "")
                    delegate: ActionButton {}
                }
            }
        }
    }

    // Close badge centered on the surface's top-left corner, macOS style.
    Rectangle {
        id: closeBadge

        x: 0
        y: 0
        width: 20
        height: 20
        radius: 10
        color: Colors.surface_container_high
        border.width: 1
        border.color: closeHover.hovered ? Colors.primary : Colors.outline_variant
        visible: card.interactive
        opacity: cardHover.hovered || closeHover.hovered ? 1 : 0
        enabled: opacity > 0

        Behavior on opacity {
            NumberAnimation {
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
            font.family: Fonts.iconFont
            font.pixelSize: 12
            color: closeHover.hovered ? Colors.primary : Colors.on_surface_variant

            Behavior on color {
                ColorAnimation {
                    duration: Theme.animations.fast
                }
            }
        }

        HoverHandler {
            id: closeHover
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: NotificationService.removeNotification(card.modelData.id)
        }
    }
}
