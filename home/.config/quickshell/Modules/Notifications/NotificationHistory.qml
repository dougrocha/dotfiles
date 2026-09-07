pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Components
import qs.Constants
import qs.Services

Column {
    id: root

    width: 322
    spacing: Theme.space.sm

    property var expandedApps: ({})

    function setExpanded(app, value) {
        const next = Object.assign({}, expandedApps);
        next[app] = value;
        expandedApps = next;
    }

    readonly property var groups: {
        const map = new Map();
        for (const n of NotificationService.history) {
            const key = n.appName || "Unknown";
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

    Repeater {
        model: ScriptModel {
            values: root.groups
            objectProp: "id"
        }

        delegate: Item {
            id: group

            required property var modelData
            readonly property bool expanded: root.expandedApps[modelData.app] === true && modelData.items.length > 1
            readonly property bool stacked: !expanded && modelData.items.length > 1

            width: root.width
            height: content.height
            clip: true

            Behavior on height {
                NumberAnimation {
                    duration: Theme.motion.fast
                    easing.type: Theme.motion.easeStandard
                }
            }

            Column {
                id: content
                width: parent.width

                spacing: 0

                Item {
                    width: parent.width
                    height: 36
                    visible: group.expanded

                    Row {
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        spacing: Theme.space.md

                        Rectangle {
                            width: showLessText.implicitWidth + 20
                            height: 24
                            radius: Theme.radius.md
                            color: showLessHover.hovered ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)
                            border.width: 1
                            border.color: Theme.stroke.hairline

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
                                id: showLessText
                                anchors.centerIn: parent
                                text: "Show less"
                                color: showLessHover.hovered ? Theme.text.primary : Theme.text.secondary
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
                                id: showLessHover
                                cursorShape: Qt.PointingHandCursor
                            }

                            TapHandler {
                                onTapped: root.setExpanded(group.modelData.app, false)
                            }
                        }

                        IconActionButton {
                            glyph: PhosphorIcons.x
                            bordered: true
                            danger: true
                            onTapped: NotificationService.clearAppHistory(group.modelData.app)
                        }
                    }
                }

                Item {
                    visible: !group.expanded
                    width: parent.width
                    height: stackCard.height + (group.stacked ? moreLink.height + 12 : 0)

                    NotificationCard {
                        id: stackCard
                        width: parent.width
                        modelData: group.modelData.items[0]
                        showTimestamp: true
                        interactive: !group.stacked
                        flat: true
                    }

                    Text {
                        id: moreLink
                        visible: group.stacked
                        x: 16
                        y: stackCard.height + 8
                        text: "+" + (group.modelData.items.length - 1) + " notification" + (group.modelData.items.length - 1 > 1 ? "s" : "")
                        color: moreLinkHover.hovered ? Theme.accent : Theme.text.secondary
                        font.family: Theme.font.ui
                        font.pixelSize: Theme.type.label.size
                        font.weight: Theme.type.label.weight

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.motion.fast
                            }
                        }

                        HoverHandler {
                            id: moreLinkHover
                            cursorShape: Qt.PointingHandCursor
                        }
                    }

                    HoverHandler {
                        enabled: group.stacked
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        enabled: group.stacked
                        onTapped: root.setExpanded(group.modelData.app, true)
                    }
                }

                Repeater {
                    model: ScriptModel {
                        values: group.expanded ? group.modelData.items : []
                        objectProp: "id"
                    }

                    delegate: NotificationCard {
                        width: content.width
                        showTimestamp: true
                        flat: true
                    }
                }
            }
        }
    }
}
