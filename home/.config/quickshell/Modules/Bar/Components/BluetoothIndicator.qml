import QtQuick
import qs.Components
import qs.Constants
import qs.Services

IconButton {
    glyph: BluetoothService.glyph
    active: BluetoothService.hasConnectedDevices || Visibilities.isOpen(Visibilities.names.bluetooth)
    activeColor: BluetoothService.hasConnectedDevices ? Theme.accent : Theme.text.primary
    tooltipText: BluetoothService.hasConnectedDevices ? "Bluetooth: connected" : (BluetoothService.powered ? "Bluetooth: on" : "Bluetooth: off")
    onTapped: Visibilities.toggle(Visibilities.names.bluetooth)
}
