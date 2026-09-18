pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.Components
import qs.Constants
import qs.Services

Column {
    id: root

    property int badgeOverhang: Theme.space.md

    spacing: Theme.space.md
    topPadding: badgeOverhang

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
            height: clipper.height

            Item {
                id: clipper

                width: parent.width
                height: content.implicitHeight
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
                    spacing: Theme.space.xs

                    Item {
                        visible: !group.expanded
                        width: parent.width
                        height: stackCard.height

                        NotificationCard {
                            id: stackCard
                            width: parent.width
                            modelData: group.modelData.items[0]
                            showTimestamp: true
                            interactive: !group.stacked
                            nested: true
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

                    Text {
                        id: moreLink
                        visible: group.stacked
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

                        TapHandler {
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
                            nested: true
                        }
                    }

                    Text {
                        id: showLess
                        visible: group.expanded
                        text: "Show less"
                        color: showLessHover.hovered ? Theme.accent : Theme.text.secondary
                        font.family: Theme.font.ui
                        font.pixelSize: Theme.type.label.size
                        font.weight: Theme.type.label.weight

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.motion.fast
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
                }
            }

            HoverHandler {
                id: groupHover
            }

            CloseBadge {
                x: -root.badgeOverhang
                y: -root.badgeOverhang
                revealed: groupHover.hovered
                onTapped: NotificationService.clearAppHistory(group.modelData.app)
            }
        }
    }
}
