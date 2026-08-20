pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Constants
import qs.Services

// History grouped per app, macOS style: each app's notifications collapse
// into a stack showing the newest card with the others peeking out below.
// Clicking the stack expands the group; a header above the expanded group
// collapses it again or clears the whole group from history.
Column {
    id: root

    width: 322
    spacing: 6

    // Session-local; every group starts collapsed.
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
                    duration: Theme.animations.fast
                    easing.type: Easing.OutCubic
                }
            }

            Column {
                id: content
                width: parent.width
                // Gaps come from each card's built-in top overhang.
                spacing: 0

                // Header buttons sit at the bottom of this item; the extra
                // height above them separates the group from the previous one.
                Item {
                    width: parent.width
                    height: 36
                    visible: group.expanded

                    Row {
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        spacing: 8

                        Rectangle {
                            width: showLessText.implicitWidth + 20
                            height: 24
                            radius: Theme.blockRadius
                            color: showLessHover.hovered ? Colors.surface_container_high : Colors.surface_container
                            border.width: 1
                            border.color: showLessHover.hovered ? Colors.primary : Colors.outline_variant

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
                                id: showLessText
                                anchors.centerIn: parent
                                text: "Show less"
                                color: showLessHover.hovered ? Colors.primary : Colors.on_surface_variant
                                font.family: Fonts.font
                                font.pixelSize: Fonts.small

                                Behavior on color {
                                    ColorAnimation {
                                        duration: Theme.animations.fast
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

                        Rectangle {
                            width: 24
                            height: 24
                            radius: Theme.blockRadius
                            color: clearHover.hovered ? Colors.surface_container_high : Colors.surface_container
                            border.width: 1
                            border.color: clearHover.hovered ? Colors.primary : Colors.outline_variant

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
                                text: Icons.close
                                color: clearHover.hovered ? Colors.primary : Colors.on_surface_variant
                                font.family: Fonts.iconFont
                                font.pixelSize: 14

                                Behavior on color {
                                    ColorAnimation {
                                        duration: Theme.animations.fast
                                    }
                                }
                            }

                            HoverHandler {
                                id: clearHover
                                cursorShape: Qt.PointingHandCursor
                            }

                            TapHandler {
                                onTapped: NotificationService.clearAppHistory(group.modelData.app)
                            }
                        }
                    }
                }

                // Collapsed: newest card on top, older ones peeking out below.
                Item {
                    visible: !group.expanded
                    width: parent.width
                    height: stackCard.height + (group.modelData.items.length > 2 ? 12 : (group.stacked ? 6 : 0))

                    Rectangle {
                        visible: group.modelData.items.length > 2
                        x: 26
                        width: parent.width - 42
                        height: 24
                        y: stackCard.height - height + 12
                        radius: 12
                        color: Colors.surface_container
                        border.width: 1
                        border.color: Colors.outline_variant
                    }

                    Rectangle {
                        visible: group.stacked
                        x: 18
                        width: parent.width - 26
                        height: 24
                        y: stackCard.height - height + 6
                        radius: 12
                        color: Colors.surface_container
                        border.width: 1
                        border.color: Colors.outline_variant
                    }

                    NotificationCard {
                        id: stackCard
                        width: parent.width
                        modelData: group.modelData.items[0]
                        showTimestamp: true
                        interactive: !group.stacked
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
                    }
                }
            }
        }
    }
}
