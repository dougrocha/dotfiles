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

    function hyprshutdown(title: string, postCommand: string): void {
        const post = postCommand ? ` --post-cmd '${postCommand}'` : "";
        Quickshell.execDetached(["hyprctl", "dispatch", `hl.dsp.exec_cmd([[hyprshutdown -t '${title}'${post}]])`]);
    }

    onOpened: {
        IdleService.refresh();
        SunsetService.refresh();
    }

    component ControlRow: PanelRow {
        id: controlRow

        required property string label
        required property bool checked

        implicitHeight: Theme.panel.menuRowHeight

        Text {
            anchors.verticalCenter: parent.verticalCenter
            textFormat: Text.PlainText
            elide: Text.ElideRight
            color: Theme.text.primary
            font.family: Theme.font.ui
            font.pixelSize: Theme.type.body.size
            anchors.left: parent.left
            anchors.right: toggleSwitch.left
            anchors.rightMargin: Theme.space.md
            text: controlRow.label
        }

        Switch {
            id: toggleSwitch
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            enabled: false
            active: controlRow.checked
        }
    }

    component BatteryRow: PanelRow {
        id: batteryRow

        required property string label
        required property int percent
        property bool charging: false
        readonly property color levelColor: charging || percent > 20 ? Theme.text.secondary : percent > 10 ? Theme.caution : Theme.danger

        implicitHeight: Theme.panel.menuRowHeight

        Text {
            anchors.verticalCenter: parent.verticalCenter
            textFormat: Text.PlainText
            elide: Text.ElideRight
            color: Theme.text.primary
            font.family: Theme.font.ui
            font.pixelSize: Theme.type.body.size
            anchors.left: parent.left
            anchors.right: batteryLevel.left
            anchors.rightMargin: Theme.space.md
            text: batteryRow.label
        }

        Row {
            id: batteryLevel
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.space.xs

            Text {
                visible: batteryRow.charging
                anchors.verticalCenter: parent.verticalCenter
                text: PhosphorIcons.batteryCharging
                color: Theme.text.secondary
                font.family: Theme.font.iconFill
                font.pixelSize: Theme.icon.xxs
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: batteryRow.percent + "%"
                color: batteryRow.levelColor
                font.family: Theme.font.ui
                font.pixelSize: Theme.type.body.size
                font.features: ({
                        "tnum": 1
                    })
            }
        }
    }

    PanelHeader {
        title: "Settings"
    }

    PanelGroup {
        label: "Controls"

        Column {
            width: parent.width

            ControlRow {
                label: "Idle lock"
                checked: IdleService.active
                onTapped: IdleService.toggle()
            }

            ControlRow {
                label: "Do not disturb"
                checked: SettingsService.doNotDisturb
                onTapped: SettingsService.doNotDisturb = !SettingsService.doNotDisturb
            }

            ControlRow {
                label: "Night light"
                checked: SunsetService.active
                onTapped: SunsetService.toggle()
            }

            ControlRow {
                label: "Microphone"
                checked: !AudioService.sourceMuted
                onTapped: AudioService.toggleSourceMute()
            }
        }
    }

    PanelGroup {
        label: "Batteries"
        visible: DeviceBatteryService.hasDevices

        Column {
            width: parent.width

            Repeater {
                model: ScriptModel {
                    values: DeviceBatteryService.upowerDevices
                }

                delegate: BatteryRow {
                    required property var modelData

                    label: modelData.model
                    percent: Math.round(modelData.percentage * 100)
                    charging: modelData.state === UPowerDeviceState.Charging
                }
            }

            Repeater {
                model: ScriptModel {
                    values: DeviceBatteryService.bluetoothDevices
                    objectProp: "address"
                }

                delegate: BatteryRow {
                    required property var modelData

                    label: modelData.name
                    percent: Math.round(modelData.battery * 100)
                }
            }
        }
    }

    Column {
        width: parent.width
        spacing: Theme.space.sm

        Divider {}

        Column {
            width: parent.width

            Repeater {
                model: [
                    {
                        label: "Lock Screen",
                        run: () => {
                            Quickshell.execDetached(["loginctl", "lock-session"]);
                            panel.close();
                        }
                    },
                    {
                        label: "Log Out",
                        run: () => panel.hyprshutdown("Logging out...", "")
                    },
                    {
                        label: "Restart",
                        run: () => panel.hyprshutdown("Restarting...", "systemctl reboot")
                    },
                    {
                        label: "Shut Down",
                        run: () => panel.hyprshutdown("Shutting down...", "shutdown -P 0")
                    }
                ]

                delegate: PanelRow {
                    id: actionRow

                    required property var modelData

                    implicitHeight: Theme.panel.menuRowHeight
                    onTapped: modelData.run()

                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: actionRow.modelData.label
                        textFormat: Text.PlainText
                        elide: Text.ElideRight
                        color: Theme.text.primary
                        font.family: Theme.font.ui
                        font.pixelSize: Theme.type.body.size
                    }
                }
            }
        }
    }
}
