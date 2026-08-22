pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
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
    // Borderless list-row style for the history panel; toasts stay card-style.
    property bool flat: false

    readonly property bool isCritical: modelData?.urgency === NotificationUrgency.Critical

    // Room for the close badge to straddle the corner; flat rows use it as a small gap instead.
    readonly property int overhang: flat ? 4 : 10

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
    property bool menuHovered: false
    property bool menuExpanded: false

    function styledBody(text) {
        return text.replace(/<a\s+href="([^"]*)"[^>]*>(.*?)<\/a>/gi, `<a href="$1"><font color="${Colors.primary}">$2</font></a>`);
    }

    function openBodyLink(link) {
        const scheme = String(link).split(":", 1)[0].toLowerCase();
        if (scheme === "http" || scheme === "https" || scheme === "mailto")
            Qt.openUrlExternally(link);
    }

    function isSettingsAction(a) {
        return /^\s*settings\s*$/i.test(a.text);
    }

    function menuActions() {
        return (card.modelData?.actions ?? []).filter(a => a.identifier !== "default" && card.isSettingsAction(a));
    }

    function buttonActions() {
        return (card.modelData?.actions ?? []).filter(a => a.identifier !== "default" && a.text !== "" && !card.isSettingsAction(a));
    }

    component ActionButton: Rectangle {
        required property var modelData

        Layout.preferredHeight: 28
        Layout.preferredWidth: actionLabel.implicitWidth + 24
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
            id: actionLabel
            anchors.centerIn: parent
            anchors.margins: 4
            text: modelData.text
            color: actionHover.hovered ? Colors.primary : Colors.on_surface_variant
            elide: Text.ElideRight
            font.family: Fonts.notificationFont
            font.pixelSize: Fonts.label.size
            font.weight: Fonts.label.weight
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

        radius: card.flat ? 8 : 12
        border.width: card.flat ? 0 : 1
        color: card.flat ? (cardHover.hovered ? Colors.surface_container_highest : Colors.surface_container_high) : Colors.surface_container
        // Critical cards never expire, so make that look deliberate.
        border.color: card.isCritical ? Colors.error : Colors.outline_variant

        Behavior on color {
            ColorAnimation {
                duration: Theme.animations.fast
            }
        }

        HoverHandler {
            id: cardHover
        }

        TapHandler {
            enabled: card.interactive
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onTapped: function (eventPoint, button) {
                if (closeHover.hovered || card.actionHovered || card.menuHovered || closeHoverInline.hovered)
                    return;
                if (card.menuExpanded) {
                    card.menuExpanded = false;
                    return;
                }
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
            anchors.margins: card.flat ? 8 : 12
            spacing: 2

            RowLayout {
                id: headerRow
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
                    font.family: Fonts.notificationFont
                    font.pixelSize: Fonts.label.size
                    font.weight: Fonts.label.weight
                    elide: Text.ElideRight
                }

                Text {
                    visible: card.showTimestamp
                    text: card.relativeTime(card.modelData?.timestamp ?? Date.now())
                    color: Colors.on_surface_variant
                    font.family: Fonts.notificationFont
                    font.pixelSize: Fonts.label.size
                    font.weight: Fonts.label.weight
                }

                Text {
                    visible: card.interactive && card.menuActions().length > 0
                    activeFocusOnTab: visible
                    text: Icons.expandMore
                    font.family: Fonts.iconFont
                    font.pixelSize: 14
                    color: menuHover.hovered ? Colors.primary : Colors.on_surface_variant
                    rotation: card.menuExpanded ? 180 : 0

                    Behavior on rotation {
                        NumberAnimation {
                            duration: Theme.animations.fast
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.animations.fast
                        }
                    }

                    HoverHandler {
                        id: menuHover
                        cursorShape: Qt.PointingHandCursor
                        onHoveredChanged: card.menuHovered = hovered
                    }

                    TapHandler {
                        onTapped: card.menuExpanded = !card.menuExpanded
                    }

                    Keys.onPressed: function (event) {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                            card.menuExpanded = !card.menuExpanded;
                            event.accepted = true;
                        }
                    }
                }

                Text {
                    visible: card.interactive && card.flat
                    opacity: cardHover.hovered || closeHoverInline.hovered ? 1 : 0
                    enabled: opacity > 0
                    text: Icons.close
                    font.family: Fonts.iconFont
                    font.pixelSize: 14
                    color: closeHoverInline.hovered ? Colors.primary : Colors.on_surface_variant

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.animations.fast
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.animations.fast
                        }
                    }

                    HoverHandler {
                        id: closeHoverInline
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        onTapped: NotificationService.removeNotification(card.modelData.id)
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: card.menuExpanded && card.menuActions().length > 0 ? popover.height + 6 : 0

                Behavior on Layout.preferredHeight {
                    NumberAnimation {
                        duration: Theme.animations.fast
                    }
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
                        font.family: Fonts.notificationFont
                        font.pixelSize: Fonts.title.size
                        font.weight: Fonts.title.weight
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: card.styledBody(card.modelData?.body ?? "")
                        visible: text !== ""
                        color: Colors.on_surface_variant
                        font.family: Fonts.notificationFont
                        font.pixelSize: Fonts.body.size
                        font.weight: Fonts.body.weight
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        onLinkActivated: link => card.openBodyLink(link)
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
                visible: card.interactive && card.buttonActions().length > 0

                Repeater {
                    model: card.buttonActions()
                    delegate: ActionButton {}
                }
            }
        }

        Rectangle {
            id: popover

            visible: card.menuExpanded && card.menuActions().length > 0
            opacity: visible ? 1 : 0
            z: 10

            x: Math.max(0, surface.width - width - 12)
            y: cardContent.y + headerRow.y + headerRow.height + cardContent.spacing
            width: popoverColumn.implicitWidth + 8
            height: popoverColumn.implicitHeight + 8

            radius: 10
            color: Colors.surface_container_high
            border.width: 1
            border.color: Colors.outline_variant

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Qt.rgba(0, 0, 0, 0.45)
                shadowBlur: 0.6
                shadowVerticalOffset: 2
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.animations.fast
                }
            }

            ColumnLayout {
                id: popoverColumn
                anchors.centerIn: parent
                spacing: 2

                Repeater {
                    model: card.menuActions()
                    delegate: Rectangle {
                        id: menuItem
                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: 26
                        Layout.preferredWidth: menuItemLabel.implicitWidth + 20
                        radius: Theme.blockRadius
                        color: menuItemHover.hovered ? Colors.surface_container_highest : "transparent"

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.animations.fast
                            }
                        }

                        Text {
                            id: menuItemLabel
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            text: menuItem.modelData.text
                            color: Colors.on_surface_variant
                            font.family: Fonts.notificationFont
                            font.pixelSize: Fonts.label.size
                            font.weight: Fonts.label.weight
                        }

                        HoverHandler {
                            id: menuItemHover
                            cursorShape: Qt.PointingHandCursor
                            onHoveredChanged: card.menuHovered = hovered
                        }

                        TapHandler {
                            onTapped: {
                                menuItem.modelData.invoke();
                                card.menuExpanded = false;
                            }
                        }
                    }
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
        visible: card.interactive && !card.flat
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
