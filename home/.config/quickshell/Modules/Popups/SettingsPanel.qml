pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.Components
import qs.Constants
import qs.Services

Column {
    id: panel

    spacing: Theme.space.xl

    function hyprshutdown(title: string, postCommand: string): void {
        const post = postCommand ? ` --post-cmd '${postCommand}'` : "";
        Quickshell.execDetached(["hyprctl", "dispatch", `hl.dsp.exec_cmd([[hyprshutdown -t '${title}'${post}]])`]);
    }

    signal closeRequested

    function refresh(): void {
        IdleService.refresh();
        SunsetService.refresh();
        LightingService.refresh();
    }

    component ControlRow: PanelRow {
        id: tile

        required property string label
        required property string glyph
        required property bool checked
        property string caption: checked ? "On" : "Off"
        property bool busy: false
        property bool alert: false

        implicitHeight: Theme.row.tile

        Rectangle {
            id: glyphCircle

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.row.action
            height: Theme.row.action
            radius: width / 2
            color: tile.checked ? Theme.accent : Theme.fill.strong

            Behavior on color {
                ColorAnimation {
                    duration: Theme.motion.fast
                }
            }

            SequentialAnimation on opacity {
                running: tile.busy
                loops: Animation.Infinite
                alwaysRunToEnd: true

                NumberAnimation {
                    to: 0.4
                    duration: Theme.motion.pulse
                }
                NumberAnimation {
                    to: 1
                    duration: Theme.motion.pulse
                }
            }

            Text {
                anchors.centerIn: parent
                text: tile.glyph
                color: tile.checked ? Theme.accentText : Theme.text.primary
                font.family: tile.checked ? Theme.font.iconFill : Theme.font.icon
                font.pixelSize: Theme.icon.sm
            }
        }

        Column {
            anchors.left: glyphCircle.right
            anchors.leftMargin: Theme.row.gap
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            Text {
                width: parent.width
                text: tile.label
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: Theme.text.primary
                font.family: Theme.font.ui
                font.pixelSize: Theme.type.body.size
            }

            Text {
                width: parent.width
                text: tile.caption
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: tile.alert ? Theme.danger : Theme.text.tertiary
                font.family: Theme.font.ui
                font.pixelSize: Theme.type.caption.size
            }
        }
    }

    component BatteryRow: PanelRow {
        id: batteryRow

        required property string label
        required property int percent
        property bool charging: false
        readonly property color levelColor: charging || percent > 20 ? Theme.text.secondary : percent > 10 ? Theme.caution : Theme.danger

        implicitHeight: Theme.row.menu

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

    Grid {
        id: controls

        readonly property int tileWidth: (width - columnSpacing) / 2

        width: parent.width
        columns: 2
        columnSpacing: Theme.panel.rowBleed * 2
        rowSpacing: Theme.space.xs

        ControlRow {
            width: controls.tileWidth
            label: "Focus"
            glyph: PhosphorIcons.moon
            checked: SettingsService.doNotDisturb
            onTapped: SettingsService.doNotDisturb = !SettingsService.doNotDisturb
        }

        ControlRow {
            width: controls.tileWidth
            label: "Night light"
            glyph: PhosphorIcons.sunHorizon
            checked: SunsetService.active
            onTapped: SunsetService.toggle()
        }

        ControlRow {
            width: controls.tileWidth
            label: "Idle lock"
            glyph: PhosphorIcons.lockSimple
            checked: IdleService.active
            onTapped: IdleService.toggle()
        }

        ControlRow {
            width: controls.tileWidth
            label: "Microphone"
            glyph: AudioService.sourceMuted ? PhosphorIcons.microphoneSlash : PhosphorIcons.microphone
            checked: !AudioService.sourceMuted
            onTapped: AudioService.toggleSourceMute()
        }

        ControlRow {
            width: controls.tileWidth
            label: "Case lights"
            glyph: LightingService.failed ? PhosphorIcons.warningCircle : PhosphorIcons.lightbulb
            checked: LightingService.shownOn && !LightingService.failed
            busy: LightingService.busy
            alert: LightingService.failed
            caption: LightingService.busy ? (LightingService.shownOn ? "Turning on" : "Turning off") : LightingService.failed ? "Failed, retry" : LightingService.on ? "On" : "Off"
            onTapped: LightingService.toggle()
        }
    }

    PanelGroup {
        label: "Batteries"
        visible: DeviceBatteryService.hasDevices

        PanelScroll {
            limit: Theme.row.menu * Theme.panel.visibleRows

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
                            panel.closeRequested();
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

                    implicitHeight: Theme.row.menu
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
