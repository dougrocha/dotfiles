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

    component ControlRow: DeviceRow {
        required property bool active

        detail: active ? "On" : "Off"
        selected: active
    }

    component BatteryRow: DeviceRow {
        id: batteryRow

        required property int percent
        property bool charging: false
        readonly property color levelColor: charging || percent > 20 ? Theme.text.secondary : percent > 10 ? Theme.caution : Theme.danger

        Text {
            visible: batteryRow.charging
            anchors.verticalCenter: parent.verticalCenter
            text: PhosphorIcons.batteryCharging
            color: Theme.accent
            font.family: Theme.font.icon
            font.pixelSize: Theme.icon.xxs
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: batteryRow.percent + "%"
            color: batteryRow.levelColor
            font.family: Theme.font.ui
            font.pixelSize: Theme.type.label.size
            font.weight: Theme.type.label.weight
        }
    }

    component PowerButton: Item {
        id: powerButton

        required property string glyph
        required property string label
        property bool danger: false

        signal tapped

        width: parent.width / 4
        height: powerColumn.implicitHeight

        Column {
            id: powerColumn

            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.space.sm

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 40
                height: 40
                radius: height / 2
                color: {
                    if (!powerHover.hovered)
                        return Theme.fill.press;
                    return powerButton.danger ? Theme.danger : Theme.fill.strong;
                }

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.motion.fast
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: powerButton.glyph
                    color: powerButton.danger && powerHover.hovered ? Theme.colors.surface : Theme.text.primary
                    font.family: Theme.font.iconFill
                    font.pixelSize: Theme.icon.sm
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: powerButton.label
                color: Theme.text.secondary
                font.family: Theme.font.ui
                font.pixelSize: Theme.type.caption.size
            }
        }

        HoverHandler {
            id: powerHover

            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: powerButton.tapped()
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
                glyph: PhosphorIcons.lockSimple
                label: "Idle lock"
                active: IdleService.active
                onTapped: IdleService.toggle()
            }

            ControlRow {
                glyph: PhosphorIcons.bellSlash
                label: "Do not disturb"
                active: SettingsService.doNotDisturb
                onTapped: SettingsService.doNotDisturb = !SettingsService.doNotDisturb
            }

            ControlRow {
                glyph: PhosphorIcons.moon
                label: "Night light"
                active: SunsetService.active
                onTapped: SunsetService.toggle()
            }

            ControlRow {
                glyph: AudioService.sourceMuted ? PhosphorIcons.microphoneSlash : PhosphorIcons.microphone
                label: "Microphone"
                active: !AudioService.sourceMuted
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

                    glyph: DeviceBatteryService.upowerIcon(modelData)
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

                    glyph: modelData.icon
                    label: modelData.name
                    percent: Math.round(modelData.battery * 100)
                }
            }
        }
    }

    Column {
        width: parent.width
        spacing: Theme.space.lg

        Divider {}

        Row {
            width: parent.width

            PowerButton {
                glyph: PhosphorIcons.lockSimple
                label: "Lock"
                onTapped: {
                    Quickshell.execDetached(["loginctl", "lock-session"]);
                    panel.close();
                }
            }

            PowerButton {
                glyph: PhosphorIcons.signOut
                label: "Log out"
                onTapped: panel.hyprshutdown("Logging out...", "")
            }

            PowerButton {
                glyph: PhosphorIcons.arrowCounterClockwise
                label: "Restart"
                onTapped: panel.hyprshutdown("Restarting...", "systemctl reboot")
            }

            PowerButton {
                glyph: PhosphorIcons.power
                label: "Shut down"
                danger: true
                onTapped: panel.hyprshutdown("Shutting down...", "shutdown -P 0")
            }
        }
    }
}
