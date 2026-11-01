import QtQuick
import qs.Components
import qs.Constants
import qs.Services

IconButton {
    glyph: BluetoothService.glyph
    plate: true
    open: Visibilities.isOpen(Visibilities.names.bluetooth)
    active: BluetoothService.hasConnectedDevices || open
    activeColor: BluetoothService.hasConnectedDevices ? Theme.accent : Theme.text.primary
    tooltipText: BluetoothService.hasConnectedDevices ? "Bluetooth: connected" : (BluetoothService.powered ? "Bluetooth: on" : "Bluetooth: off")
    onTapped: Visibilities.toggle(Visibilities.names.bluetooth)
}
