import QtQuick
import Quickshell
import qs.Components
import qs.Constants
import qs.Services

IconButton {
    glyph: BluetoothService.hasConnectedDevices ? PhosphorIcons.bluetoothConnected : (BluetoothService.bluetoothEnabled ? PhosphorIcons.bluetooth : PhosphorIcons.bluetoothSlash)
    active: BluetoothService.hasConnectedDevices || Visibilities.bluetoothPanel
    activeColor: BluetoothService.hasConnectedDevices ? Theme.accent : Theme.text.primary
    tooltipText: BluetoothService.hasConnectedDevices ? "Bluetooth: Connected" : (BluetoothService.bluetoothEnabled ? "Bluetooth: On" : "Bluetooth: Off")
    onTapped: Visibilities.toggleBluetoothPanel()
}
