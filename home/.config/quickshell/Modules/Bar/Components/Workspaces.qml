import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Constants
import qs.Services

Item {
    id: root

    required property var monitor

    implicitWidth: mainLayout.implicitWidth
    implicitHeight: Theme.topBarHeight

    readonly property var activeWorkspace: monitor?.activeWorkspace
    readonly property bool onNamedWorkspace: !!activeWorkspace && !/^\d+$/.test(activeWorkspace.name) && !activeWorkspace.name.startsWith("special:")

    RowLayout {
        id: mainLayout
        anchors.centerIn: parent
        spacing: 0

        Row {
            spacing: 0
            Layout.alignment: Qt.AlignVCenter

            Repeater {
                model: Hyprland.workspaces

                delegate: Item {
                    required property var modelData

                    readonly property bool belongsToMonitor: modelData.id >= 0 && /^\d+$/.test(modelData.name) && modelData.monitor === root.monitor
                    readonly property bool isActive: modelData.active
                    readonly property bool hasWindows: (modelData.lastIpcObject?.windows ?? 0) > 0

                    readonly property int resizeDuration: 120
                    readonly property int stateDuration: 100

                    readonly property int dotSize: 10

                    visible: width > 0
                    width: belongsToMonitor ? dotSize + Theme.space.xs : 0
                    height: Theme.topBarHeight - 8

                    Behavior on width {
                        NumberAnimation {
                            duration: resizeDuration
                            easing.type: Theme.motion.easeStandard
                        }
                    }

                    Rectangle {
                        id: dot
                        anchors.centerIn: parent
                        width: Math.min(parent.dotSize, parent.width)
                        height: parent.dotSize
                        radius: Theme.radius.xs
                        color: isActive ? Theme.accent : Theme.withAlpha(Theme.accent, hasWindows ? 0.15 : 0.0)
                        border.color: isActive ? Theme.withAlpha(Theme.accent, 0) : Theme.accent
                        border.width: 1.5
                        opacity: isActive || hasWindows ? 1.0 : 0.5

                        Behavior on color {
                            ColorAnimation {
                                duration: dot.parent.stateDuration
                            }
                        }
                        Behavior on opacity {
                            NumberAnimation {
                                duration: dot.parent.stateDuration
                                easing.type: Theme.motion.easeStandard
                            }
                        }
                        Behavior on border.color {
                            ColorAnimation {
                                duration: dot.parent.stateDuration
                            }
                        }
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }
                    TapHandler {
                        onTapped: {
                            Visibilities.closePopups();
                            modelData.activate();
                        }
                    }
                }
            }
        }

        Item {
            clip: true
            implicitHeight: 16
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: root.onNamedWorkspace ? namedBadge.implicitWidth + 3 : 0
            Layout.leftMargin: root.onNamedWorkspace ? 3 : 0

            Behavior on Layout.preferredWidth {
                NumberAnimation {
                    duration: Theme.motion.fast
                    easing.type: Theme.motion.easeStandard
                }
            }
            Behavior on Layout.leftMargin {
                NumberAnimation {
                    duration: Theme.motion.fast
                    easing.type: Theme.motion.easeStandard
                }
            }

            Rectangle {
                id: namedBadge
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                implicitWidth: namedLabel.implicitWidth + 16
                height: 16
                radius: Theme.radius.md
                color: Theme.fill.selected

                Text {
                    id: namedLabel
                    anchors.centerIn: parent
                    renderType: Text.NativeRendering
                    text: root.activeWorkspace?.name ?? ""
                    color: Theme.accent
                    font.family: Theme.font.ui
                    font.pixelSize: Theme.type.label.size
                    font.weight: Theme.type.label.weight
                    font.letterSpacing: Theme.type.label.tracking
                }
            }
        }
    }
}
