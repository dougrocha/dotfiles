import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import qs.Components
import qs.Constants
import qs.Services

Popup {
    id: panel

    shown: Visibilities.bluetoothPanel
    onDismissed: Visibilities.bluetoothPanel = false

    component DeviceEntry: Rectangle {
        id: entry

        required property var row

        readonly property string action: BluetoothService.pendingAction(row.address)

        readonly property bool hovered: rowMouse.containsMouse
        readonly property string statusText: {
            if (action === "forgetting")
                return "Forgetting";
            if (action === "disconnecting" || row.state === BluetoothDeviceState.Disconnecting)
                return "Disconnecting";
            if (action === "pairing")
                return "Pairing";
            if (action === "connecting" || row.state === BluetoothDeviceState.Connecting)
                return "Connecting";
            if (row.connected)
                return BluetoothService.batteryLabel(row.address) || "Connected";
            return "";
        }

        width: parent.width
        height: 34
        radius: Theme.radius.md

        color: entry.hovered ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

        Behavior on color {
            ColorAnimation {
                duration: Theme.motion.fast
            }
        }

        MouseArea {
            id: rowMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: BluetoothService.activate(entry.row)
        }

        Text {
            id: entryIcon
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            text: entry.row.icon
            color: entry.row.connected ? Theme.accent : Theme.text.secondary
            font.pixelSize: Theme.icon.xs
            font.family: Theme.font.icon

            Behavior on color {
                ColorAnimation {
                    duration: Theme.motion.fast
                }
            }
        }

        Column {
            anchors.left: entryIcon.right
            anchors.leftMargin: 8
            anchors.right: forgetButton.left
            anchors.rightMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.space.xxs

            Text {
                width: parent.width
                text: entry.row.label
                color: entry.row.connected ? Theme.text.primary : Theme.text.secondary
                font.pixelSize: Theme.type.body.size
                font.family: Theme.font.ui
                font.weight: entry.row.connected ? Font.Medium : Font.Normal
                elide: Text.ElideRight
            }

            Text {
                visible: entry.statusText !== ""
                width: parent.width
                text: entry.statusText
                color: entry.row.connected ? Theme.accent : Theme.text.secondary
                font.pixelSize: Theme.type.caption.size
                font.family: Theme.font.ui
                elide: Text.ElideRight
            }
        }

        IconActionButton {
            id: forgetButton
            visible: entry.row.known && entry.hovered
            anchors.right: parent.right
            anchors.rightMargin: Theme.space.xs
            anchors.verticalCenter: parent.verticalCenter
            size: 22
            circular: true
            danger: true
            glyph: PhosphorIcons.x
            onTapped: BluetoothService.forget(entry.row)
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
                text: "Bluetooth"
                color: Theme.text.primary
                font.pixelSize: Theme.type.display.size
                font.weight: Theme.type.display.weight
                font.family: Theme.font.ui
            }
        }

        ToggleRow {
            width: parent.width
            glyph: BluetoothService.hasConnectedDevices ? PhosphorIcons.bluetoothConnected : (active ? PhosphorIcons.bluetooth : PhosphorIcons.bluetoothSlash)
            label: BluetoothService.statusText.replace(/^Bluetooth\s+/, "")
            active: BluetoothService.bluetoothEnabled
            onToggled: BluetoothService.togglePower()
        }

        Column {
            width: parent.width
            spacing: Theme.space.sm
            visible: BluetoothService.connectedRows.length > 0

            Item {
                width: parent.width
                height: 4
            }

            Text {
                text: "Connected"
                color: Theme.text.secondary
                font.pixelSize: Theme.type.caption.size
                font.weight: Font.Medium
                font.family: Theme.font.ui
            }

            Column {
                width: parent.width
                spacing: Theme.space.xxs

                Repeater {
                    model: ScriptModel {
                        values: BluetoothService.connectedRows
                        objectProp: "address"
                    }

                    delegate: DeviceEntry {
                        required property var modelData
                        row: modelData
                    }
                }
            }
        }

        Column {
            width: parent.width
            spacing: Theme.space.sm
            visible: BluetoothService.pairedRows.length > 0

            Divider {
                visible: BluetoothService.connectedRows.length > 0
            }

            Item {
                width: parent.width
                height: 4
                visible: BluetoothService.connectedRows.length === 0
            }

            Text {
                text: "Paired"
                color: Theme.text.primary
                font.pixelSize: Theme.type.body.size
                font.weight: Font.Medium
                font.family: Theme.font.ui
            }

            Flickable {
                width: parent.width
                height: Math.min(pairedColumn.implicitHeight, 240)
                contentHeight: pairedColumn.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                interactive: contentHeight > height

                Column {
                    id: pairedColumn
                    width: parent.width
                    spacing: Theme.space.xxs

                    Repeater {
                        model: ScriptModel {
                            values: BluetoothService.pairedRows
                            objectProp: "address"
                        }

                        delegate: DeviceEntry {
                            required property var modelData
                            row: modelData
                        }
                    }
                }
            }
        }

        Text {
            visible: BluetoothService.connectedRows.length === 0 && BluetoothService.pairedRows.length === 0
            width: parent.width
            text: {
                if (!BluetoothService.adapter)
                    return "No Bluetooth adapter";
                if (!BluetoothService.bluetoothEnabled)
                    return "Turn Bluetooth on";
                return "No paired devices";
            }
            color: Theme.text.secondary
            font.pixelSize: Theme.type.body.size
            font.family: Theme.font.ui
            wrapMode: Text.WordWrap
        }

        PopupActionButton {
            label: "Bluetui"
            leftAlign: true
            onTapped: {
                Visibilities.bluetoothPanel = false;
                bluetoothSettingsProc.running = true;
            }
        }
    }

    Process {
        id: bluetoothSettingsProc
        command: ["launch-or-focus-tui", "bluetui"]
    }
}
