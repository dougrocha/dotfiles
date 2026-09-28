import QtQuick
import Quickshell
import qs.Components
import qs.Constants
import qs.Services

IconButton {
    glyph: BluetoothService.glyph
    active: BluetoothService.hasConnectedDevices || Visibilities.isOpen("bluetooth-panel")
    activeColor: BluetoothService.hasConnectedDevices ? Theme.accent : Theme.text.primary
    tooltipText: BluetoothService.hasConnectedDevices ? "Bluetooth: Connected" : (BluetoothService.powered ? "Bluetooth: On" : "Bluetooth: Off")
    onTapped: Visibilities.toggle("bluetooth-panel")
}
