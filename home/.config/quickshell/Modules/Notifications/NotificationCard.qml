pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Constants
import qs.Services

Rectangle {
    id: card

    required property var modelData

    height: cardContent.implicitHeight + 12 * 2

    radius: 12
    border.width: 1
    color: Colors.surface_container
    border.color: Colors.outline_variant

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

    HoverHandler {
        id: cardHover
    }

    TapHandler {
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
            font.pixelSize: Fonts.p - 2
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
                font.pixelSize: Fonts.p - 2
                elide: Text.ElideRight
            }

            Text {
                text: Icons.close
                font.family: Fonts.iconFont
                font.pixelSize: Fonts.h5
                color: Colors.on_surface_variant
                opacity: cardHover.hovered ? 1 : 0
                enabled: cardHover.hovered

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.animations.fast
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: NotificationService.removeNotification(card.modelData.id)
                    onContainsMouseChanged: closeHover.hovered = containsMouse
                }

                HoverHandler {
                    id: closeHover
                }
            }
        }

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
            font.pixelSize: Fonts.p - 2
            font.weight: Font.Normal
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            elide: Text.ElideRight
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
