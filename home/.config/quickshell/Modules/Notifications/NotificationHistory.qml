pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import qs.Components
import qs.Constants
import qs.Services

Column {
    id: root

    property int bleed: Theme.space.sm

    readonly property int groupGap: Theme.space.lg

    property var expandedApps: ({})

    function setExpanded(app, value) {
        const next = Object.assign({}, expandedApps);
        next[app] = value;
        expandedApps = next;
    }

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

    readonly property var groups: {
        const map = new Map();
        for (const n of NotificationService.history) {
            const key = NotificationService.appDisplayName(n.appName);
            if (!map.has(key))
                map.set(key, {
                    id: key,
                    app: key,
                    items: []
                });
            map.get(key).items.push(n);
        }
        return [...map.values()];
    }

    component TextLink: Text {
        id: link

        signal tapped

        color: linkHover.hovered ? Theme.text.primary : Theme.text.secondary
        font.family: Theme.font.ui
        font.pixelSize: Theme.type.label.size
        font.weight: Theme.type.label.weight

        Behavior on color {
            ColorAnimation {
                duration: Theme.motion.fast
            }
        }

        HoverHandler {
            id: linkHover
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: link.tapped()
        }
    }

    component HistoryRow: Item {
        id: row

        required property var modelData

        readonly property bool isCritical: modelData.urgency === NotificationUrgency.Critical

        height: rowContent.implicitHeight + Theme.space.sm * 2

        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: -root.bleed
            anchors.rightMargin: -root.bleed
            radius: Theme.radius.md
            color: rowHover.hovered ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

            Behavior on color {
                ColorAnimation {
                    duration: Theme.motion.fast
                }
            }
        }

        HoverHandler {
            id: rowHover
        }

        ColumnLayout {
            id: rowContent

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.space.xxs

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.space.sm

                Rectangle {
                    visible: row.isCritical
                    Layout.preferredWidth: 6
                    Layout.preferredHeight: 6
                    Layout.alignment: Qt.AlignVCenter
                    radius: 3
                    color: Theme.danger
                }

                Text {
                    Layout.fillWidth: true
                    text: row.modelData.summary || row.modelData.body
                    color: Theme.text.primary
                    font.family: Theme.font.ui
                    font.pixelSize: Theme.type.body.size
                    font.weight: Theme.type.title.weight
                    elide: Text.ElideRight
                }

                Item {
                    Layout.preferredWidth: Math.max(timeLabel.implicitWidth, Theme.icon.xs)
                    Layout.preferredHeight: timeLabel.implicitHeight

                    Text {
                        id: timeLabel
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        opacity: rowHover.hovered ? 0 : 1
                        text: root.relativeTime(row.modelData.timestamp ?? Date.now())
                        color: Theme.text.tertiary
                        font.family: Theme.font.ui
                        font.pixelSize: Theme.type.caption.size

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Theme.motion.fast
                            }
                        }
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        opacity: rowHover.hovered ? 1 : 0
                        enabled: opacity > 0
                        text: PhosphorIcons.x
                        color: dismissHover.hovered ? Theme.text.primary : Theme.text.secondary
                        font.family: Theme.font.icon
                        font.pixelSize: Theme.icon.xs

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Theme.motion.fast
                            }
                        }

                        HoverHandler {
                            id: dismissHover
                            cursorShape: Qt.PointingHandCursor
                        }

                        TapHandler {
                            onTapped: NotificationService.removeNotification(row.modelData.id)
                        }
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                visible: row.modelData.summary !== "" && text !== ""
                text: NotificationService.styledBody(row.modelData.body)
                textFormat: Text.StyledText
                color: Theme.text.secondary
                font.family: Theme.font.ui
                font.pixelSize: Theme.type.body.size
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
                onLinkActivated: link => NotificationService.openBodyLink(link)
            }
        }
    }

    Repeater {
        model: ScriptModel {
            values: root.groups
            objectProp: "id"
        }

        delegate: Column {
            id: group

            required property var modelData
            required property int index

            readonly property int count: modelData.items.length
            readonly property bool expanded: root.expandedApps[modelData.app] === true && count > 1

            width: root.width

            Item {
                width: parent.width
                height: root.groupGap
                visible: group.index > 0
            }

            Divider {
                visible: group.index > 0
                bleed: root.bleed
            }

            Item {
                width: parent.width
                height: root.groupGap
                visible: group.index > 0
            }

            RowLayout {
                width: parent.width
                height: 16
                spacing: Theme.space.sm

                SectionLabel {
                    Layout.fillWidth: true
                    text: group.modelData.app
                    elide: Text.ElideRight
                }

                TextLink {
                    visible: group.count > 1
                    text: group.expanded ? "Show less" : group.count + " notifications"
                    onTapped: root.setExpanded(group.modelData.app, !group.expanded)
                }

                IconActionButton {
                    size: 16
                    circular: true
                    glyphSize: Theme.icon.xxs
                    glyph: PhosphorIcons.x
                    opacity: groupHover.hovered ? 1 : 0
                    enabled: opacity > 0
                    onTapped: NotificationService.clearAppHistory(group.modelData.app)

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.motion.fast
                        }
                    }
                }
            }

            Item {
                id: clipper

                x: -root.bleed
                width: parent.width + root.bleed * 2
                height: rows.implicitHeight
                clip: true

                Behavior on height {
                    NumberAnimation {
                        duration: Theme.motion.fast
                        easing.type: Theme.motion.easeStandard
                    }
                }

                Column {
                    id: rows
                    x: root.bleed
                    width: parent.width - root.bleed * 2

                    Repeater {
                        model: ScriptModel {
                            values: group.expanded ? group.modelData.items : group.modelData.items.slice(0, 1)
                            objectProp: "id"
                        }

                        delegate: HistoryRow {
                            width: rows.width
                        }
                    }
                }
            }

            HoverHandler {
                id: groupHover
            }
        }
    }
}
