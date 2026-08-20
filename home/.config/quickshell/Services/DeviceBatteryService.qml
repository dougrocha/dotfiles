pragma Singleton
import QtQml
import Quickshell
import Quickshell.Services.UPower
import qs.Constants

Singleton {
    id: root

    // UPower gear, minus bluez-mirrored batteries (would double-row) and offline paths.
    readonly property var upowerDevices: UPower.devices.values.filter(d => d.ready && d.isPresent && !d.isLaptopBattery && !d.powerSupply && d.state !== UPowerDeviceState.Unknown && !d.nativePath.startsWith("/org/bluez"))

    // Project to primitives; live BluetoothDevice objects can be destroyed by BlueZ churn mid-incubation.
    readonly property var bluetoothDevices: BluetoothService.connectedDevices.filter(d => d.batteryAvailable).map(d => ({
                address: d.address,
                name: BluetoothService.deviceLabel(d),
                battery: d.battery,
                icon: BluetoothService.deviceIcon(d.icon)
            }))

    readonly property bool hasDevices: upowerDevices.length > 0 || bluetoothDevices.length > 0

    // HID++ misreports kinds; trust UPower types only for audio.
    function upowerIcon(device) {
        if (device.type === UPowerDeviceType.Headset || device.type === UPowerDeviceType.Headphones)
            return PhosphorIcons.headphones;
        return PhosphorIcons.mouse;
    }
}
