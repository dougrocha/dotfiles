pragma Singleton
import QtQml
import Quickshell
import Quickshell.Services.UPower
import qs.Constants

Singleton {
    id: root

    readonly property var upowerDevices: UPower.devices.values.filter(d => d.ready && d.isPresent && !d.isLaptopBattery && !d.powerSupply && (d.state !== UPowerDeviceState.Unknown || d.percentage > 0) && !d.nativePath.startsWith("/org/bluez"))

    readonly property var bluetoothDevices: BluetoothService.connectedDevices.filter(d => d.batteryAvailable).map(d => ({
                address: d.address,
                name: BluetoothService.deviceLabel(d),
                battery: d.battery,
                icon: BluetoothService.deviceIcon(d.icon)
            }))

    readonly property bool hasDevices: upowerDevices.length > 0 || bluetoothDevices.length > 0

    function upowerIcon(device) {
        if (device.type === UPowerDeviceType.Headset || device.type === UPowerDeviceType.Headphones)
            return PhosphorIcons.headphones;
        return PhosphorIcons.mouse;
    }
}
