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

    component PowerRow: Rectangle {
        id: powerRow

        property string iconText: ""
        property string label: ""
        property bool danger: false

        signal tapped

        readonly property bool highlighted: powerHover.hovered || activeFocus

        activeFocusOnTab: true
        width: parent.width
        height: 30
        radius: Theme.radius.sm
        color: "transparent"

        Rectangle {
            z: -1
            anchors.fill: parent
            anchors.leftMargin: -panel.rowBleed
            anchors.rightMargin: -panel.rowBleed
            radius: parent.radius
            color: powerRow.highlighted ? (powerRow.danger ? Theme.withAlpha(Theme.danger, 0.10) : Theme.fill.hover) : Theme.withAlpha(Theme.fill.hover, 0)

            Behavior on color {
                ColorAnimation {
                    duration: Theme.motion.fast
                }
            }
        }

        Text {
            id: powerIcon
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: powerRow.iconText
            color: powerRow.highlighted ? (powerRow.danger ? Theme.danger : Theme.accent) : Theme.text.secondary
            font.pixelSize: Theme.icon.sm
            font.family: Theme.font.icon

            Behavior on color {
                ColorAnimation {
                    duration: Theme.motion.fast
                }
            }
        }

        Text {
            anchors.left: powerIcon.right
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: powerRow.label
            color: Theme.text.primary
            font.pixelSize: Theme.type.body.size
            font.family: Theme.font.ui
            elide: Text.ElideRight
        }

        HoverHandler {
            id: powerHover
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler {
            onTapped: powerRow.tapped()
        }
        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                powerRow.tapped();
                event.accepted = true;
            }
        }
    }

    Column {
        width: parent.width
        spacing: Theme.space.sm

        ToggleRow {
            width: parent.width
            style: "switch"
            bleed: panel.rowBleed
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
            spacing: 0

            Divider {}

            Item {
                width: parent.width
                height: Theme.space.sm
            }

            PowerRow {
                iconText: PhosphorIcons.lockSimple
                label: "Lock"
                onTapped: {
                    lockProcess.running = true;
                    Visibilities.settingsPanel = false;
                }
            }

            PowerRow {
                iconText: PhosphorIcons.signOut
                label: "Log out"
                onTapped: logoutProcess.running = true
            }

            PowerRow {
                iconText: PhosphorIcons.arrowCounterClockwise
                label: "Restart"
                onTapped: rebootProcess.running = true
            }

            PowerRow {
                iconText: PhosphorIcons.power
                label: "Shut down"
                danger: true
                onTapped: shutdownProcess.running = true
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
