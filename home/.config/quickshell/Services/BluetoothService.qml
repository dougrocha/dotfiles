pragma Singleton
import QtQml
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool adapterPowered: adapter?.state === BluetoothAdapterState.Enabled || adapter?.state === BluetoothAdapterState.Enabling
    readonly property list<BluetoothDevice> devices: adapter?.devices.values ?? []
    readonly property list<BluetoothDevice> connectedDevices: devices.filter(d => d.connected)
    readonly property list<BluetoothDevice> pairedDevices: devices.filter(d => d.paired)

    readonly property bool bluetoothEnabled: adapterPowered
    readonly property bool hasConnectedDevices: connectedDevices.length > 0
    readonly property int connectedDeviceCount: connectedDevices.length
    readonly property string statusText: {
        if (!adapterPowered)
            return "Bluetooth Off";
        if (connectedDevices.length === 0)
            return "No Devices Connected";
        if (connectedDevices.length === 1)
            return "1 Device Connected";
        return connectedDevices.length + " Devices Connected";
    }

    function togglePower() {
        if (adapter)
            adapter.enabled = !adapter.enabled;
    }

    function enableBluetooth() {
        if (adapter && !adapter.enabled)
            adapter.enabled = true;
    }

    function disableBluetooth() {
        if (adapter && adapter.enabled)
            adapter.enabled = false;
    }

    function isDeviceConnected(address) {
        return connectedDevices.some(d => d.address === address);
    }

    function isDevicePaired(address) {
        return pairedDevices.some(d => d.address === address);
    }

    function connectDevice(address) {
        const device = devices.find(d => d.address === address);
        if (device)
            device.connect();
    }

    function disconnectDevice(address) {
        const device = devices.find(d => d.address === address);
        if (device)
            device.disconnect();
    }

    function pairDevice(address) {
        const device = devices.find(d => d.address === address);
        if (device)
            device.pair();
    }

    function removeDevice(address) {
        const device = devices.find(d => d.address === address);
        if (device)
            device.forget();
    }
}
