pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.Components
import qs.Constants
import qs.Services

Popup {
    id: panel

    panelName: Visibilities.names.settings
    cardWidth: 300

    function hyprshutdown(title: string, postCommand: string): void {
        const post = postCommand ? ` --post-cmd '${postCommand}'` : "";
        Quickshell.execDetached(["hyprctl", "dispatch", `hl.dsp.exec_cmd([[hyprshutdown -t '${title}'${post}]])`]);
    }

    onOpened: {
        IdleService.refresh();
        SunsetService.refresh();
    }

    component SwitchRow: ToggleRow {
        width: parent.width
        style: "switch"
        bleed: Theme.panel.rowBleed
    }

    component DeviceBatteryRow: Item {
        id: deviceRow

        property string iconText: ""
        property string name: ""
        property int pct: 0
        property bool charging: false

        width: parent.width
        height: 32

        readonly property color batteryColor: charging || pct > 20 ? Theme.text.secondary : pct > 10 ? Theme.caution : Theme.danger

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

    Column {
        width: parent.width
        spacing: Theme.space.sm

        SwitchRow {
            glyph: PhosphorIcons.lockSimple
            label: "Idle lock"
            active: IdleService.active
            onToggled: IdleService.toggle()
        }

        SwitchRow {
            glyph: PhosphorIcons.bellSlash
            label: "Do not disturb"
            active: SettingsService.doNotDisturb
            onToggled: SettingsService.doNotDisturb = !SettingsService.doNotDisturb
        }

        SwitchRow {
            glyph: PhosphorIcons.moon
            label: "Night light"
            active: SunsetService.active
            onToggled: SunsetService.toggle()
        }

        SwitchRow {
            glyph: AudioService.sourceMuted ? PhosphorIcons.microphoneSlash : PhosphorIcons.microphone
            label: "Microphone"
            active: !AudioService.sourceMuted
            onToggled: AudioService.toggleSourceMute()
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

            PopupActionButton {
                glyph: PhosphorIcons.lockSimple
                label: "Lock"
                onTapped: {
                    Quickshell.execDetached(["loginctl", "lock-session"]);
                    panel.close();
                }
            }

            PopupActionButton {
                glyph: PhosphorIcons.signOut
                label: "Log out"
                onTapped: panel.hyprshutdown("Logging out...", "")
            }

            PopupActionButton {
                glyph: PhosphorIcons.arrowCounterClockwise
                label: "Restart"
                onTapped: panel.hyprshutdown("Restarting...", "systemctl reboot")
            }

            PopupActionButton {
                glyph: PhosphorIcons.power
                label: "Shut down"
                danger: true
                onTapped: panel.hyprshutdown("Shutting down...", "shutdown -P 0")
            }
        }
    }
}
