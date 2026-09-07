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

    property bool showTimestamp: false

    property bool interactive: true

    property bool flat: false

    readonly property bool isCritical: modelData?.urgency === NotificationUrgency.Critical

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
        return text.replace(/<a\s+href="([^"]*)"[^>]*>(.*?)<\/a>/gi, `<a href="$1"><font color="${Theme.accent}">$2</font></a>`);
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
        radius: Theme.radius.md
        color: actionHover.hovered ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)
        border.color: Theme.stroke.hairline
        border.width: 1

        Behavior on color {
            ColorAnimation {
                duration: Theme.motion.fast
            }
        }
        Behavior on border.color {
            ColorAnimation {
                duration: Theme.motion.fast
            }
        }

        Text {
            id: actionLabel
            anchors.centerIn: parent
            anchors.margins: 4
            text: modelData.text
            color: actionHover.hovered ? Theme.text.primary : Theme.text.secondary
            elide: Text.ElideRight
            font.family: Theme.font.ui
            font.pixelSize: Theme.type.label.size
            font.weight: Theme.type.label.weight
            Behavior on color {
                ColorAnimation {
                    duration: Theme.motion.fast
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

        radius: card.flat ? Theme.radius.md : Theme.radius.xl
        border.width: card.flat ? 0 : 1
        color: card.flat ? (cardHover.hovered ? Theme.colors.overlay : Theme.colors.raised) : Theme.colors.surface
        border.color: card.isCritical ? Theme.danger : Theme.stroke.hairline

        Behavior on color {
            ColorAnimation {
                duration: Theme.motion.fast
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
            spacing: Theme.space.xxs

            RowLayout {
                id: headerRow
                Layout.fillWidth: true
                spacing: Theme.space.sm

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
                    color: Theme.text.secondary
                    font.family: Theme.font.ui
                    font.pixelSize: Theme.type.label.size
                    font.weight: Theme.type.label.weight
                    elide: Text.ElideRight
                }

                Text {
                    visible: card.showTimestamp
                    text: card.relativeTime(card.modelData?.timestamp ?? Date.now())
                    color: Theme.text.secondary
                    font.family: Theme.font.ui
                    font.pixelSize: Theme.type.label.size
                    font.weight: Theme.type.label.weight
                }

                Text {
                    visible: card.interactive && card.menuActions().length > 0
                    activeFocusOnTab: visible
                    text: PhosphorIcons.caretDown
                    font.family: Theme.font.icon
                    font.pixelSize: Theme.icon.xs
                    color: menuHover.hovered ? Theme.text.primary : Theme.text.secondary
                    rotation: card.menuExpanded ? 180 : 0

                    Behavior on rotation {
                        NumberAnimation {
                            duration: Theme.motion.fast
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.motion.fast
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
                    text: PhosphorIcons.x
                    font.family: Theme.font.icon
                    font.pixelSize: Theme.icon.xs
                    color: closeHoverInline.hovered ? Theme.text.primary : Theme.text.secondary

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.motion.fast
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.motion.fast
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
                        duration: Theme.motion.fast
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.space.md

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.space.sm

                    Text {
                        Layout.fillWidth: true
                        text: card.modelData?.summary ?? ""
                        visible: text !== ""
                        color: Theme.text.primary
                        font.family: Theme.font.ui
                        font.pixelSize: Theme.type.title.size
                        font.weight: Theme.type.title.weight
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: card.styledBody(card.modelData?.body ?? "")
                        visible: text !== ""
                        color: Theme.text.secondary
                        font.family: Theme.font.ui
                        font.pixelSize: Theme.type.body.size
                        font.weight: Theme.type.body.weight
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
                    radius: Theme.radius.md
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
                spacing: Theme.space.md
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

            radius: Theme.radius.lg
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

            ColumnLayout {
                id: popoverColumn
                anchors.centerIn: parent
                spacing: Theme.space.xxs

                Repeater {
                    model: card.menuActions()
                    delegate: Rectangle {
                        id: menuItem
                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: 26
                        Layout.preferredWidth: menuItemLabel.implicitWidth + 20
                        radius: Theme.radius.md
                        color: menuItemHover.hovered ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.motion.fast
                            }
                        }

                        Text {
                            id: menuItemLabel
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            text: menuItem.modelData.text
                            color: Theme.text.secondary
                            font.family: Theme.font.ui
                            font.pixelSize: Theme.type.label.size
                            font.weight: Theme.type.label.weight
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

    Rectangle {
        id: closeBadge

        x: 0
        y: 0
        width: 20
        height: 20
        radius: width / 2
        color: Theme.colors.raised
        border.width: 1
        border.color: closeHover.hovered ? Theme.stroke.accent : Theme.stroke.hairline
        visible: card.interactive && !card.flat
        opacity: cardHover.hovered || closeHover.hovered ? 1 : 0
        enabled: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.motion.fast
            }
        }
        Behavior on border.color {
            ColorAnimation {
                duration: Theme.motion.fast
            }
        }

        Text {
            anchors.centerIn: parent
            text: PhosphorIcons.x
            font.family: Theme.font.icon
            font.pixelSize: Theme.icon.xxs
            color: closeHover.hovered ? Theme.text.primary : Theme.text.tertiary

            Behavior on color {
                ColorAnimation {
                    duration: Theme.motion.fast
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
