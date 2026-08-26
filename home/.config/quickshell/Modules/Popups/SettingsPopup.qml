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

        readonly property color batteryColor: pct <= 10 && !charging ? Colors.error : Colors.primary

        Text {
            id: deviceIcon
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: deviceRow.iconText
            color: deviceRow.batteryColor
            font.pixelSize: 16
            font.family: Fonts.phosphorFont
        }

        Text {
            anchors.left: deviceIcon.right
            anchors.leftMargin: 10
            anchors.right: batteryStatus.left
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            text: deviceRow.name
            color: Colors.on_surface
            font.pixelSize: Fonts.body.size
            font.family: Fonts.font
            elide: Text.ElideRight
        }

        Row {
            id: batteryStatus
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            Text {
                visible: deviceRow.charging
                anchors.verticalCenter: parent.verticalCenter
                text: PhosphorIcons.batteryCharging
                color: Colors.primary
                font.pixelSize: 13
                font.family: Fonts.phosphorFont
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 44
                height: 5
                radius: height / 2
                color: Colors.outline_variant
                clip: true

                Rectangle {
                    width: parent.width * Math.max(0, Math.min(100, deviceRow.pct)) / 100
                    height: parent.height
                    radius: parent.radius
                    color: deviceRow.batteryColor

                    Behavior on width {
                        NumberAnimation {
                            duration: Theme.animations.normal
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.animations.fast
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
                font.pixelSize: Fonts.label.size
                font.weight: Fonts.label.weight
                font.family: Fonts.font
            }
        }
    }

    component PowerButton: Rectangle {
        id: powerButton

        property string iconText: ""
        property string label: ""
        property color accent: Colors.primary

        signal tapped

        activeFocusOnTab: true
        height: 44
        radius: Theme.blockRadius
        color: powerHover.hovered || activeFocus ? Colors.surface_container_high : Colors.surface_container

        Behavior on color {
            ColorAnimation {
                duration: Theme.animations.fast
            }
        }

        Text {
            id: powerIcon
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            text: powerButton.iconText
            color: powerButton.accent
            font.pixelSize: 18
            font.family: Fonts.phosphorFont
        }

        Text {
            anchors.left: powerIcon.right
            anchors.leftMargin: 9
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            text: powerButton.label
            color: Colors.on_surface
            font.pixelSize: Fonts.body.size
            font.weight: Font.Medium
            font.family: Fonts.font
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
        spacing: 6

        Item {
            width: parent.width
            height: 24

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "System"
                color: Colors.on_surface
                font.pixelSize: 16
                font.weight: Font.Medium
                font.family: Fonts.font
            }
        }

        Rectangle {
            id: idleRow

            readonly property bool active: IdleService.active

            width: parent.width
            height: 34
            radius: Theme.blockRadius
            activeFocusOnTab: true
            color: active ? Colors.primary : (idleHover.hovered || activeFocus ? Colors.surface_container_high : Colors.surface_container)

            Behavior on color {
                ColorAnimation {
                    duration: Theme.animations.fast
                }
            }

            Text {
                id: idleIcon
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: PhosphorIcons.lockSimple
                color: idleRow.active ? Colors.on_primary : Colors.on_surface_variant
                font.pixelSize: 15
                font.family: Fonts.phosphorFont

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animations.fast
                    }
                }
            }

            Text {
                anchors.left: idleIcon.right
                anchors.leftMargin: 8
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: "Idle lock"
                color: idleRow.active ? Colors.on_primary : Colors.on_surface
                font.pixelSize: Fonts.body.size
                font.family: Fonts.font
                elide: Text.ElideRight

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animations.fast
                    }
                }
            }

            HoverHandler {
                id: idleHover
                cursorShape: Qt.PointingHandCursor
            }
            TapHandler {
                onTapped: IdleService.toggle(true)
            }
            Keys.onPressed: function (event) {
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                    IdleService.toggle(true);
                    event.accepted = true;
                }
            }
        }

        Column {
            width: parent.width
            spacing: 6
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
                spacing: 2

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
            spacing: 8

            Divider {}

            Row {
                width: parent.width
                spacing: 8

                PowerButton {
                    width: (parent.width - 8) / 2
                    iconText: PhosphorIcons.lockSimple
                    label: "Lock"
                    accent: Colors.secondary
                    onTapped: {
                        lockProcess.running = true;
                        Visibilities.settingsPanel = false;
                    }
                }

                PowerButton {
                    width: (parent.width - 8) / 2
                    iconText: PhosphorIcons.signOut
                    label: "Log out"
                    accent: Colors.primary
                    onTapped: logoutProcess.running = true
                }
            }

            Row {
                width: parent.width
                spacing: 8

                PowerButton {
                    width: (parent.width - 8) / 2
                    iconText: PhosphorIcons.arrowCounterClockwise
                    label: "Restart"
                    accent: Colors.tertiary
                    onTapped: rebootProcess.running = true
                }

                PowerButton {
                    width: (parent.width - 8) / 2
                    iconText: PhosphorIcons.power
                    label: "Shut down"
                    accent: Colors.error
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
