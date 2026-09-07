pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth
import qs.Constants

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

    readonly property var namedDevices: devices.filter(d => hasHumanName(d))
    readonly property var connectedRows: sortedRows(namedDevices.filter(d => d.connected))
    readonly property var pairedRows: sortedRows(namedDevices.filter(d => !d.connected && isKnown(d)))

    function deviceLabel(device) {
        if (!device)
            return "";
        return String(device.deviceName || device.name || "").trim();
    }

    function isKnown(device) {
        return device.paired || device.bonded || device.trusted;
    }

    function hasHumanName(device) {
        const label = deviceLabel(device);
        if (label === "")
            return false;
        const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
        const address = /^([0-9a-f]{2}[:-]){5}[0-9a-f]{2}$/i;
        return !uuid.test(label) && !address.test(label);
    }

    function deviceRow(device) {
        return {
            address: device.address,
            label: deviceLabel(device),
            connected: device.connected,
            known: isKnown(device),
            state: device.state,
            icon: deviceIcon(device.icon)
        };
    }

    function batteryLabel(address) {
        const device = deviceFor(address);
        if (!device || !device.batteryAvailable)
            return "";
        return Math.round(device.battery * 100) + "%";
    }

    function sortedRows(list) {
        return list.map(d => deviceRow(d)).sort((a, b) => a.label.localeCompare(b.label));
    }

    function deviceFor(address) {
        return devices.find(d => d.address === address) ?? null;
    }

    function deviceIcon(icon) {
        const name = icon || "";
        if (name.includes("audio") || name.includes("headset"))
            return PhosphorIcons.headphones;
        if (name.includes("mouse"))
            return PhosphorIcons.mouse;
        if (name.includes("keyboard"))
            return PhosphorIcons.keyboard;
        return PhosphorIcons.bluetooth;
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
        const device = deviceFor(address);
        if (device)
            device.connect();
    }

    function disconnectDevice(address) {
        const device = deviceFor(address);
        if (device)
            device.disconnect();
    }

    function pairDevice(address) {
        const device = deviceFor(address);
        if (device)
            device.pair();
    }

    function removeDevice(address) {
        const device = deviceFor(address);
        if (device)
            device.forget();
    }

    property var pendingActions: ({})

    function pendingAction(address) {
        return pendingActions[address] ?? "";
    }

    function setPending(address, action) {
        const next = Object.assign({}, pendingActions);
        next[address] = action;
        pendingActions = next;
        pendingTimeout.restart();
    }

    function activate(row) {
        if (row.connected) {
            setPending(row.address, "disconnecting");
            disconnectDevice(row.address);
            return;
        }
        if (row.known) {
            setPending(row.address, "connecting");
            connectDevice(row.address);
            return;
        }
        setPending(row.address, "pairing");
        pairDevice(row.address);
    }

    function forget(row) {
        setPending(row.address, "forgetting");
        removeDevice(row.address);
    }

    function syncPending() {
        const next = ({});
        let changed = false;

        for (const address in pendingActions) {
            const action = pendingActions[address];
            const device = deviceFor(address);

            if (!device) {
                changed = true;
                continue;
            }

            if (action === "pairing") {
                if (!device.paired) {
                    next[address] = action;
                } else if (device.connected) {

                    changed = true;
                } else {
                    device.trusted = true;
                    device.connect();
                    next[address] = "connecting";
                    changed = true;
                }
                continue;
            }

            const settled = (action === "connecting" && device.connected) || (action === "disconnecting" && !device.connected) || (action === "forgetting" && !isKnown(device));

            if (settled)
                changed = true;
            else
                next[address] = action;
        }

        if (changed)
            pendingActions = next;
    }

    onConnectedRowsChanged: syncPending()
    onPairedRowsChanged: syncPending()

    Timer {
        id: pendingTimeout
        interval: 20000
        onTriggered: root.pendingActions = ({})
    }
}
