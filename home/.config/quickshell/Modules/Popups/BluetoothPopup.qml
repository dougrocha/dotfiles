pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.Components
import qs.Constants
import qs.Services

Popup {
    id: panel

    readonly property var devices: BluetoothService.connectedRows.concat(BluetoothService.pairedRows)

    panelName: Visibilities.names.bluetooth

    PanelHeader {
        title: "Bluetooth"

        Switch {
            active: BluetoothService.powered
            onToggled: BluetoothService.togglePower()
        }
    }

    PanelGroup {
        label: "Devices"
        visible: panel.devices.length > 0

        Column {
            width: parent.width

            Repeater {
                model: ScriptModel {
                    values: panel.devices
                    objectProp: "address"
                }

                delegate: DeviceRow {
                    id: deviceRow

                    required property var modelData

                    glyph: modelData.icon
                    label: modelData.label
                    detail: BluetoothService.rowStatus(modelData)
                    selected: modelData.connected
                    onTapped: BluetoothService.activate(modelData)

                    IconActionButton {
                        visible: deviceRow.modelData.known && deviceRow.hovered
                        size: 22
                        circular: true
                        danger: true
                        glyph: PhosphorIcons.x
                        onTapped: BluetoothService.forget(deviceRow.modelData)
                    }
                }
            }
        }
    }

    Text {
        visible: panel.devices.length === 0
        width: parent.width
        text: {
            if (!BluetoothService.available)
                return "No Bluetooth adapter";
            if (!BluetoothService.powered)
                return "Bluetooth is off";
            return "No paired devices";
        }
        color: Theme.text.tertiary
        font.family: Theme.font.ui
        font.pixelSize: Theme.type.body.size
        wrapMode: Text.WordWrap
    }

    PanelFooterLink {
        label: "Bluetooth Settings…"
        command: ["launch-or-focus-tui", "bluetui"]
    }
}
