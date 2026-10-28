pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Services.Notifications
import qs.Components
import qs.Constants
import qs.Services
import "NotificationFormat.js" as NotificationFormat

Item {
    id: card

    required property var modelData

    readonly property bool isCritical: modelData?.urgency === NotificationUrgency.Critical

    height: surface.height

    readonly property bool hasDefaultAction: (card.modelData?.actions ?? []).some(a => a.identifier === "default")

    property bool actionHovered: false
    property bool menuHovered: false
    property bool menuExpanded: false

    function isSettingsAction(a) {
        return /^\s*settings\s*$/i.test(a.text);
    }

    readonly property bool menuShown: menuExpanded && menuActions.length > 0

    readonly property var menuActions: (card.modelData?.actions ?? []).filter(a => a.identifier !== "default" && card.isSettingsAction(a))
    readonly property var buttonActions: (card.modelData?.actions ?? []).filter(a => a.identifier !== "default" && a.text !== "" && !card.isSettingsAction(a))

    component ActionButton: Rectangle {
        required property var modelData

        Layout.fillWidth: true
        Layout.preferredHeight: 28
        radius: Theme.radius.md
        color: actionHover.hovered ? Theme.fill.strong : Theme.fill.hover

        Behavior on color {
            ColorAnimation {
                duration: Theme.motion.fast
            }
        }

        Text {
            anchors.fill: parent
            anchors.leftMargin: Theme.space.md
            anchors.rightMargin: Theme.space.md
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: modelData.text
            color: Theme.text.primary
            elide: Text.ElideRight
            font.family: Theme.font.ui
            font.pixelSize: Theme.type.label.size
            font.weight: Theme.type.label.weight
        }

        HoverHandler {
            id: actionHover
            cursorShape: Qt.PointingHandCursor
            onHoveredChanged: card.actionHovered = hovered
        }

        TapHandler {
            onTapped: NotificationService.invokeAction(card.modelData.id, modelData.identifier)
        }
    }

    Rectangle {
        id: surface

        width: card.width
        height: cardContent.implicitHeight + Theme.space.lg * 2

        radius: Theme.radius.xl
        border.width: 1
        color: card.isCritical ? Qt.tint(Theme.colors.surface, Theme.withAlpha(Theme.danger, 0.12)) : Theme.colors.surface
        border.color: card.isCritical ? Theme.withAlpha(Theme.danger, 0.6) : Theme.stroke.hairline

        HoverHandler {
            id: cardHover
        }

        TapHandler {
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onTapped: function (eventPoint, button) {
                if (card.actionHovered || card.menuHovered)
                    return;
                if (card.menuExpanded) {
                    card.menuExpanded = false;
                    return;
                }
                if (button === Qt.RightButton || !card.hasDefaultAction)
                    NotificationService.dismiss(card.modelData.id);
                else
                    NotificationService.invokeAction(card.modelData.id, "default");
            }
        }

        ColumnLayout {
            id: cardContent
            anchors.fill: parent
            anchors.margins: Theme.space.lg
            spacing: Theme.space.md

            ColumnLayout {
                id: textColumn
                Layout.fillWidth: true
                spacing: Theme.space.xxs

                RowLayout {
                    id: headerRow
                    Layout.fillWidth: true
                    spacing: Theme.space.sm

                    Text {
                        Layout.fillWidth: true
                        text: card.modelData?.summary || NotificationService.appDisplayName(card.modelData?.appName ?? "")
                        color: Theme.text.primary
                        font.family: Theme.font.ui
                        font.pixelSize: Theme.type.title.size
                        font.weight: Theme.type.title.weight
                        elide: Text.ElideRight
                    }

                    Text {
                        visible: !!card.modelData?.summary
                        text: NotificationService.appDisplayName(card.modelData?.appName ?? "")
                        color: Theme.text.tertiary
                        font.family: Theme.font.ui
                        font.pixelSize: Theme.type.caption.size
                    }

                    Text {
                        Layout.leftMargin: Theme.space.xs
                        text: NotificationFormat.relativeTime(card.modelData?.timestamp ?? Date.now())
                        color: Theme.text.tertiary
                        font.family: Theme.font.ui
                        font.pixelSize: Theme.type.caption.size
                    }

                    Text {
                        visible: card.menuActions.length > 0
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
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: card.menuShown ? popover.height + Theme.space.sm : 0

                    SizeMotion on Layout.preferredHeight {}
                }

                Text {
                    Layout.fillWidth: true
                    text: NotificationFormat.styledBody(card.modelData?.body ?? "", Theme.accent)
                    visible: text !== ""
                    color: Theme.text.secondary
                    font.family: Theme.font.ui
                    font.pixelSize: Theme.type.body.size
                    font.weight: Theme.type.body.weight
                    wrapMode: Text.WordWrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                    onLinkActivated: link => NotificationFormat.openBodyLink(link)
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.space.sm
                visible: card.buttonActions.length > 0

                Repeater {
                    model: card.buttonActions
                    delegate: ActionButton {}
                }
            }
        }

        Rectangle {
            id: popover

            visible: card.menuShown
            opacity: visible ? 1 : 0
            z: 10

            x: Math.max(0, surface.width - width - Theme.space.lg)
            y: cardContent.y + textColumn.y + headerRow.y + headerRow.height + textColumn.spacing
            width: popoverColumn.implicitWidth + Theme.space.md
            height: popoverColumn.implicitHeight + Theme.space.md

            radius: Theme.radius.md
            color: Theme.colors.raised
            border.width: 1
            border.color: Theme.stroke.hairline

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Theme.withAlpha(Theme.shadow, 0.45)
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
                    model: card.menuActions
                    delegate: Rectangle {
                        id: menuItem
                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: 26
                        Layout.preferredWidth: menuItemLabel.implicitWidth + 20
                        radius: Theme.radius.sm
                        color: menuItemHover.hovered ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.motion.fast
                            }
                        }

                        Text {
                            id: menuItemLabel
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.space.md
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
                                NotificationService.invokeAction(card.modelData.id, menuItem.modelData.identifier);
                                card.menuExpanded = false;
                            }
                        }
                    }
                }
            }
        }
    }

    CloseBadge {
        readonly property real cornerInset: surface.radius * (1 - Math.SQRT1_2)

        x: Math.round(cornerInset - width / 2)
        y: Math.round(cornerInset - height / 2)
        revealed: cardHover.hovered
        onTapped: NotificationService.dismiss(card.modelData.id)
    }
}
