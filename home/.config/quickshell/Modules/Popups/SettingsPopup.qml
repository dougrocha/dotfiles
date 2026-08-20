import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import Quickshell.Widgets
import qs.Components
import qs.Constants
import qs.Services

PopupWindow {
    id: panel

    color: "transparent"

    implicitWidth: card.cardWidth
    implicitHeight: {
        const win = anchor.window;
        return (win && win.screen) ? Math.max(400, win.screen.height - win.height - 12) : 800;
    }

    mask: Region {
        item: card
    }

    visible: Visibilities.settingsPanel

    PopupGrab {
        popup: panel
        onDismissed: Visibilities.settingsPanel = false
    }

    onVisibleChanged: {
        if (visible) {
            IdleService.refresh();
            SunsetService.refresh();
        }
    }

    component Tile: Rectangle {
        id: tile
        property string label: ""
        property bool active: false
        property color accent: Colors.primary

        signal tapped

        height: 28
        radius: Theme.blockRadius
        color: active ? Qt.rgba(accent.r, accent.g, accent.b, 0.15) : tileHover.hovered ? Colors.surface_container_high : Colors.surface_container
        border.color: (active || tileHover.hovered) ? accent : Colors.outline_variant
        border.width: 1

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
            elide: Text.ElideRight
            text: parent.label
            color: (parent.active || tileHover.hovered) ? parent.accent : Colors.on_surface_variant
            font.pixelSize: Fonts.small
            font.family: Fonts.font
            Behavior on color {
                ColorAnimation {
                    duration: Theme.animations.fast
                }
            }
        }

        HoverHandler {
            id: tileHover
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler {
            onTapped: parent.tapped()
        }
    }

    component PowerTile: Rectangle {
        property string iconText: ""
        property color iconColor: Colors.on_surface_variant

        signal tapped

        height: 36
        radius: Theme.blockRadius
        color: pwHover.hovered ? Colors.surface_container_high : Colors.surface_container

        Behavior on color {
            ColorAnimation {
                duration: Theme.animations.fast
            }
        }

        Text {
            anchors.centerIn: parent
            text: parent.iconText
            color: parent.iconColor
            font.pixelSize: Fonts.h2
            font.family: Fonts.phosphorFont
        }

        HoverHandler {
            id: pwHover
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler {
            onTapped: parent.tapped()
        }
    }

    component DeviceBatteryRow: Item {
        id: deviceRow

        property string iconText: ""
        property string name: ""
        property int pct: 0
        property bool charging: false

        width: parent.width
        height: 20

        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: deviceRow.iconText
            color: Colors.primary
            font.pixelSize: Fonts.p
            font.family: Fonts.phosphorFont
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 26
            anchors.right: pctText.left
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            text: deviceRow.name
            color: Colors.on_surface_variant
            font.pixelSize: Fonts.small
            font.family: Fonts.font
            elide: Text.ElideRight
        }

        Text {
            visible: deviceRow.charging
            anchors.right: pctText.left
            anchors.rightMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            text: PhosphorIcons.batteryCharging
            color: Colors.primary
            font.pixelSize: Fonts.p
            font.family: Fonts.phosphorFont
        }

        Text {
            id: pctText
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: deviceRow.pct + "%"
            color: deviceRow.pct <= 10 && !deviceRow.charging ? Colors.error : Colors.on_surface_variant
            font.pixelSize: Fonts.small
            font.family: Fonts.font
            Behavior on color {
                ColorAnimation {
                    duration: Theme.animations.fast
                }
            }
        }
    }

    PopupCard {
        id: card

        readonly property int cardWidth: 280

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        shown: Visibilities.settingsPanel
        onDismissed: Visibilities.settingsPanel = false

        Item {
            width: parent.width
            height: 24

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "Settings"
                color: Colors.on_surface
                font.pixelSize: Fonts.h4
                font.family: Fonts.font
                font.weight: Font.DemiBold
            }

            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 24
                height: 24
                radius: 12
                color: closeHover.hovered ? Colors.surface_container_high : "transparent"
                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animations.fast
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: Icons.closeSmall
                    color: Colors.on_surface_variant
                    font.family: Fonts.iconFont
                    font.pixelSize: Fonts.h4
                }

                HoverHandler {
                    id: closeHover
                    cursorShape: Qt.PointingHandCursor
                }
                TapHandler {
                    onTapped: Visibilities.settingsPanel = false
                }
            }
        }

        PopupDivider {}

        SectionLabel {
            text: "CONNECTIONS"
        }

        Rectangle {
            width: parent.width
            height: 28
            radius: Theme.blockRadius
            color: btHover.hovered ? Colors.surface_container_high : Colors.surface_container
            border.color: BluetoothService.bluetoothEnabled ? Colors.primary : Colors.outline_variant
            border.width: 1

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
                id: btIcon
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: BluetoothService.hasConnectedDevices ? Icons.bluetoothConnected : Icons.bluetooth
                color: BluetoothService.bluetoothEnabled ? Colors.primary : Colors.on_surface_variant
                font.pixelSize: Fonts.h5
                font.family: Fonts.iconFont
                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animations.fast
                    }
                }
            }

            Text {
                anchors.left: btIcon.right
                anchors.leftMargin: 8
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: {
                    if (!BluetoothService.bluetoothEnabled)
                        return "Off";
                    if (BluetoothService.connectedDevices.length === 0)
                        return "Not connected";
                    return BluetoothService.connectedDevices.map(d => BluetoothService.deviceLabel(d)).join(", ");
                }
                color: BluetoothService.bluetoothEnabled ? Colors.on_surface : Colors.on_surface_variant
                font.pixelSize: Fonts.small
                font.family: Fonts.font
                elide: Text.ElideRight
                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animations.fast
                    }
                }
            }

            HoverHandler {
                id: btHover
                cursorShape: Qt.PointingHandCursor
            }
            TapHandler {
                onTapped: Visibilities.openBluetoothPanel()
            }
        }

        // Wrapped so the divider and label vanish together when nothing has a battery.
        Column {
            width: parent.width
            spacing: Theme.popup.spacing
            visible: DeviceBatteryService.hasDevices

            PopupDivider {}

            SectionLabel {
                text: "DEVICES"
            }

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

        PopupDivider {}

        SectionLabel {
            text: "QUICK"
        }

        Row {
            width: parent.width
            spacing: 8

            Tile {
                width: (parent.width - 8) / 2
                label: "Idle"
                active: IdleService.active
                onTapped: IdleService.toggle()
            }

            Tile {
                width: (parent.width - 8) / 2
                label: "Night"
                active: SunsetService.active
                onTapped: SunsetService.toggle()
            }
        }

        // Hidden while recording; the island owns stopping it.
        Column {
            width: parent.width
            spacing: Theme.popup.spacing
            visible: !StreamingService.isRecordingScreen

            PopupDivider {}

            SectionLabel {
                text: "RECORD"
            }

            Row {
                id: recordRow

                readonly property var targets: ["screen"].concat(Quickshell.screens.map(s => s.name))

                width: parent.width
                spacing: 8

                Repeater {
                    model: recordRow.targets

                    delegate: Tile {
                        required property string modelData

                        width: (recordRow.width - 8 * (recordRow.targets.length - 1)) / recordRow.targets.length
                        label: modelData === "screen" ? "Full" : modelData
                        onTapped: {
                            recordProcess.command = ["start-recording", modelData];
                            recordProcess.running = true;
                            Visibilities.settingsPanel = false;
                        }
                    }
                }
            }
        }

        PopupDivider {}

        Row {
            width: parent.width
            spacing: 8

            PowerTile {
                width: (parent.width - 24) / 4
                iconText: PhosphorIcons.power
                iconColor: Colors.error
                onTapped: shutdownProcess.running = true
            }

            PowerTile {
                width: (parent.width - 24) / 4
                iconText: PhosphorIcons.arrowCounterClockwise
                iconColor: Colors.tertiary
                onTapped: rebootProcess.running = true
            }

            PowerTile {
                width: (parent.width - 24) / 4
                iconText: PhosphorIcons.signOut
                iconColor: Colors.primary
                onTapped: logoutProcess.running = true
            }

            PowerTile {
                width: (parent.width - 24) / 4
                iconText: PhosphorIcons.lockSimple
                iconColor: Colors.secondary
                onTapped: {
                    lockProcess.running = true;
                    Visibilities.settingsPanel = false;
                }
            }
        }
    }

    Process {
        id: recordProcess
        command: ["start-recording", "screen"]
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
