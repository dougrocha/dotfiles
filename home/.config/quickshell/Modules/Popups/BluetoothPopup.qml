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

        readonly property bool hovered: rowMouse.hovered
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
        radius: Theme.radius.sm
        color: "transparent"

        Rectangle {
            z: -1
            anchors.fill: parent
            anchors.leftMargin: -panel.rowBleed
            anchors.rightMargin: -panel.rowBleed
            radius: parent.radius
            color: entry.hovered ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

            Behavior on color {
                ColorAnimation {
                    duration: Theme.motion.fast
                }
            }
        }

        HoverHandler {
            id: rowMouse
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler {
            onTapped: BluetoothService.activate(entry.row)
        }

        Text {
            id: entryIcon
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: entry.row.icon
            color: entry.row.connected ? Theme.accent : Theme.text.secondary
            font.pixelSize: Theme.icon.sm
            font.family: Theme.font.icon

            Behavior on color {
                ColorAnimation {
                    duration: Theme.motion.fast
                }
            }
        }

        Column {
            anchors.left: entryIcon.right
            anchors.leftMargin: 10
            anchors.right: forgetButton.left
            anchors.rightMargin: Theme.space.sm
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.space.xxs

            Text {
                width: parent.width
                text: entry.row.label
                color: entry.row.connected ? Theme.text.primary : Theme.text.secondary
                font.pixelSize: Theme.type.body.size
                font.family: Theme.font.ui
                font.weight: entry.row.connected ? Theme.type.title.weight : Theme.type.body.weight
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

        ToggleRow {
            width: parent.width
            style: "switch"
            bleed: panel.rowBleed
            glyph: BluetoothService.hasConnectedDevices ? PhosphorIcons.bluetoothConnected : (active ? PhosphorIcons.bluetooth : PhosphorIcons.bluetoothSlash)
            label: "Bluetooth"
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

            SectionLabel {
                text: "CONNECTED"
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

            Item {
                width: parent.width
                height: 4
            }

            SectionLabel {
                text: "PAIRED"
            }

            Flickable {
                id: pairedScroll
                x: -panel.rowBleed
                width: parent.width + panel.rowBleed * 2
                height: Math.min(pairedColumn.implicitHeight, 240)
                contentHeight: pairedColumn.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                interactive: contentHeight > height

                Column {
                    id: pairedColumn
                    x: panel.rowBleed
                    width: pairedScroll.width - panel.rowBleed * 2
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

        Divider {}

        PopupActionButton {
            label: "Bluetui"
            bleed: panel.rowBleed
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
