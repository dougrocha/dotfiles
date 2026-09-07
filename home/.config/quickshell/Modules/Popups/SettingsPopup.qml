import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import qs.Components
import qs.Constants
import qs.Services

Popup {
    id: panel

    shown: Visibilities.settingsPanel
    onDismissed: Visibilities.settingsPanel = false

    onVisibleChanged: {
        if (visible)
            IdleService.refresh();
    }

    component DeviceBatteryRow: Item {
        id: deviceRow

        property string iconText: ""
        property string name: ""
        property int pct: 0
        property bool charging: false

        width: parent.width
        height: 32

        readonly property color batteryColor: pct <= 10 && !charging ? Theme.danger : Theme.accent

        Text {
            id: deviceIcon
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: deviceRow.iconText
            color: deviceRow.batteryColor
            font.pixelSize: Theme.icon.sm
            font.family: Theme.font.icon
        }

        Text {
            anchors.left: deviceIcon.right
            anchors.leftMargin: 10
            anchors.right: batteryStatus.left
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            text: deviceRow.name
            color: Theme.text.primary
            font.pixelSize: Theme.type.body.size
            font.family: Theme.font.ui
            elide: Text.ElideRight
        }

        Row {
            id: batteryStatus
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.space.sm

            Text {
                visible: deviceRow.charging
                anchors.verticalCenter: parent.verticalCenter
                text: PhosphorIcons.batteryCharging
                color: Theme.accent
                font.pixelSize: Theme.icon.xxs
                font.family: Theme.font.icon
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 44
                height: 5
                radius: height / 2
                color: Theme.stroke.strong
                clip: true

                Rectangle {
                    width: parent.width * Math.max(0, Math.min(100, deviceRow.pct)) / 100
                    height: parent.height
                    radius: parent.radius
                    color: deviceRow.batteryColor

                    Behavior on width {
                        NumberAnimation {
                            duration: Theme.motion.normal
                            easing.type: Theme.motion.easeStandard
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.motion.fast
                        }
                    }
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: 30
                horizontalAlignment: Text.AlignRight
                text: deviceRow.pct + "%"
                color: deviceRow.batteryColor
                font.pixelSize: Theme.type.label.size
                font.weight: Theme.type.label.weight
                font.family: Theme.font.ui
            }
        }
    }

    component PowerButton: Rectangle {
        id: powerButton

        property string iconText: ""
        property string label: ""
        property color accent: Theme.accent

        signal tapped

        activeFocusOnTab: true
        height: 44
        radius: Theme.radius.md
        color: powerHover.hovered || activeFocus ? Theme.colors.overlay : Theme.colors.raised

        Behavior on color {
            ColorAnimation {
                duration: Theme.motion.fast
            }
        }

        Text {
            id: powerIcon
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            text: powerButton.iconText
            color: powerButton.accent
            font.pixelSize: Theme.icon.md
            font.family: Theme.font.icon
        }

        Text {
            anchors.left: powerIcon.right
            anchors.leftMargin: 9
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            text: powerButton.label
            color: Theme.text.primary
            font.pixelSize: Theme.type.body.size
            font.weight: Font.Medium
            font.family: Theme.font.ui
            elide: Text.ElideRight
        }

        HoverHandler {
            id: powerHover
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler {
            onTapped: powerButton.tapped()
        }
        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                powerButton.tapped();
                event.accepted = true;
            }
        }
    }

    Column {
        width: parent.width
        spacing: Theme.space.sm

        Item {
            width: parent.width
            height: 24

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "System"
                color: Theme.text.primary
                font.pixelSize: Theme.type.display.size
                font.weight: Theme.type.display.weight
                font.family: Theme.font.ui
            }
        }

        ToggleRow {
            width: parent.width
            glyph: PhosphorIcons.lockSimple
            label: "Idle lock"
            active: IdleService.active
            onToggled: IdleService.toggle(true)
        }

        Column {
            width: parent.width
            spacing: Theme.space.sm
            visible: DeviceBatteryService.hasDevices

            Item {
                width: parent.width
                height: 4
            }

            SectionLabel {
                text: "DEVICES"
            }

            Column {
                width: parent.width
                spacing: Theme.space.xxs

                Repeater {
                    model: ScriptModel {
                        values: DeviceBatteryService.upowerDevices
                    }

                    delegate: DeviceBatteryRow {
                        required property var modelData
                        iconText: DeviceBatteryService.upowerIcon(modelData)
                        name: modelData.model
                        pct: Math.round(modelData.percentage * 100)
                        charging: modelData.state === UPowerDeviceState.Charging
                    }
                }

                Repeater {
                    model: ScriptModel {
                        values: DeviceBatteryService.bluetoothDevices
                        objectProp: "address"
                    }

                    delegate: DeviceBatteryRow {
                        required property var modelData
                        iconText: modelData.icon
                        name: modelData.name
                        pct: Math.round(modelData.battery * 100)
                    }
                }
            }
        }

        Column {
            width: parent.width
            spacing: Theme.space.md

            Divider {}

            Row {
                width: parent.width
                spacing: Theme.space.md

                PowerButton {
                    width: (parent.width - 8) / 2
                    iconText: PhosphorIcons.lockSimple
                    label: "Lock"
                    accent: Theme.accent
                    onTapped: {
                        lockProcess.running = true;
                        Visibilities.settingsPanel = false;
                    }
                }

                PowerButton {
                    width: (parent.width - 8) / 2
                    iconText: PhosphorIcons.signOut
                    label: "Log out"
                    accent: Theme.accent
                    onTapped: logoutProcess.running = true
                }
            }

            Row {
                width: parent.width
                spacing: Theme.space.md

                PowerButton {
                    width: (parent.width - 8) / 2
                    iconText: PhosphorIcons.arrowCounterClockwise
                    label: "Restart"
                    accent: Theme.accent
                    onTapped: rebootProcess.running = true
                }

                PowerButton {
                    width: (parent.width - 8) / 2
                    iconText: PhosphorIcons.power
                    label: "Shut down"
                    accent: Theme.danger
                    onTapped: shutdownProcess.running = true
                }
            }
        }
    }

    Process {
        id: lockProcess
        command: ["loginctl", "lock-session"]
    }

    Process {
        id: shutdownProcess
        command: ["sh", "-c", "hyprctl dispatch \"hl.dsp.exec_cmd([[hyprshutdown -t 'Shutting down...' --post-cmd 'shutdown -P 0']])\""]
    }

    Process {
        id: rebootProcess
        command: ["sh", "-c", "hyprctl dispatch \"hl.dsp.exec_cmd([[hyprshutdown -t 'Restarting...' --post-cmd 'systemctl reboot']])\""]
    }

    Process {
        id: logoutProcess
        command: ["sh", "-c", "hyprctl dispatch \"hl.dsp.exec_cmd([[hyprshutdown -t 'Logging out...']])\""]
    }
}
