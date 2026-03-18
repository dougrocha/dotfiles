pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Bluetooth adapter and device tracking
    property bool adapterPowered: false
    property bool adapterDiscovering: false
    property list<QtObject> devices: []
    property var connectedDevices: ([])
    property var pairedDevices: ([])

    // Overall Bluetooth status
    readonly property bool bluetoothEnabled: adapterPowered
    readonly property bool hasConnectedDevices: connectedDevices.length > 0
    readonly property int connectedDeviceCount: connectedDevices.length
    readonly property string statusText: {
        if (!adapterPowered)
            return "Bluetooth Off";
        if (adapterDiscovering)
            return "Scanning...";
        if (connectedDevices.length === 0)
            return "No Devices Connected";
        if (connectedDevices.length === 1)
            return "1 Device Connected";
        return connectedDevices.length + " Devices Connected";
    }

    // Get connection status of a specific device
    function isDeviceConnected(deviceAddress) {
        return connectedDevices.some(dev => dev.address === deviceAddress);
    }

    // Get paired status of a specific device
    function isDevicePaired(deviceAddress) {
        return pairedDevices.some(dev => dev.address === deviceAddress);
    }

    // Toggle Bluetooth power
    function togglePower() {
        powerToggleProcess.running = true;
    }

    // Enable Bluetooth
    function enableBluetooth() {
        if (!adapterPowered) {
            powerToggleProcess.running = true;
        }
    }

    // Disable Bluetooth
    function disableBluetooth() {
        if (adapterPowered) {
            powerToggleProcess.running = true;
        }
    }

    // Refresh device list
    function refreshDevices() {
        listDevicesProcess.running = true;
    }

    // Connect to a device
    function connectDevice(deviceAddress) {
        connectDeviceProcess.command = ["bluetoothctl", "connect", deviceAddress];
        connectDeviceProcess.running = true;
    }

    // Disconnect a device
    function disconnectDevice(deviceAddress) {
        disconnectDeviceProcess.command = ["bluetoothctl", "disconnect", deviceAddress];
        disconnectDeviceProcess.running = true;
    }

    // Pair with a device
    function pairDevice(deviceAddress) {
        pairDeviceProcess.command = ["bluetoothctl", "pair", deviceAddress];
        pairDeviceProcess.running = true;
    }

    // Remove a paired device
    function removeDevice(deviceAddress) {
        removeDeviceProcess.command = ["bluetoothctl", "remove", deviceAddress];
        removeDeviceProcess.running = true;
    }

    // Start scanning for devices
    function startScan() {
        if (adapterPowered) {
            scanProcess.running = true;
        }
    }

    // Stop scanning for devices
    function stopScan() {
        scanStopProcess.running = true;
    }

    // Initial refresh on service creation
    Component.onCompleted: {
        refreshStatus();
        refreshDevices();
    }

    // Refresh overall Bluetooth status
    function refreshStatus() {
        statusProcess.running = true;
    }

    // Parse device information from bluetoothctl output
    function parseDeviceList(output) {
        const lines = output.trim().split('\n');
        const devices = [];
        const connectedList = [];
        const pairedList = [];

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i].trim();

            // Match device lines: Device <address> <name>
            const deviceMatch = line.match(/^Device\s+([0-9A-Fa-f:]+)\s+(.+)$/);
            if (deviceMatch) {
                const address = deviceMatch[1];
                const name = deviceMatch[2];

                // Check if next line indicates connection status
                let connected = false;
                let paired = false;

                if (i + 1 < lines.length) {
                    const nextLine = lines[i + 1].trim().toLowerCase();
                    connected = nextLine.includes("connected: yes");
                    paired = nextLine.includes("paired: yes");
                }

                const device = {
                    address: address,
                    name: name,
                    connected: connected,
                    paired: paired
                };

                devices.push(device);

                if (connected) {
                    connectedList.push(device);
                }
                if (paired) {
                    pairedList.push(device);
                }
            }
        }

        root.devices = devices;
        root.connectedDevices = connectedList;
        root.pairedDevices = pairedList;
    }

    // Parse power status
    function parsePowerStatus(output) {
        const powered = output.trim().toLowerCase() === "yes";
        root.adapterPowered = powered;
    }

    // Parse adapter discovering status
    function parseDiscoveringStatus(output) {
        const discovering = output.trim().toLowerCase() === "yes";
        root.adapterDiscovering = discovering;
    }

    // Process: Get overall Bluetooth power status
    Process {
        id: statusProcess

        command: ["bluetoothctl", "show"]
        stdout: SplitParser {
            onRead: data => {
                // Parse power status from "Powered: yes/no"
                const lines = data.split('\n');
                for (let line of lines) {
                    if (line.includes("Powered:")) {
                        const powered = line.includes("yes");
                        root.adapterPowered = powered;
                    }
                    if (line.includes("Discovering:")) {
                        const discovering = line.includes("yes");
                        root.adapterDiscovering = discovering;
                    }
                }
            }
        }
    }

    // Process: List all devices
    Process {
        id: listDevicesProcess

        command: ["bluetoothctl", "devices"]
        stdout: SplitParser {
            onRead: data => {
                parseDeviceList(data);
                // After getting devices, refresh their status
                statusProcess.running = true;
            }
        }
    }

    // Process: Toggle Bluetooth power
    Process {
        id: powerToggleProcess

        command: ["bluetoothctl", "power", "toggle"]
        onExited: (exitCode, exitStatus) => {
            // Refresh status after toggling
            statusProcess.running = true;
            listDevicesProcess.running = true;
        }
    }

    // Process: Connect to device
    Process {
        id: connectDeviceProcess

        onExited: (exitCode, exitStatus) => {
            // Refresh device list after connection attempt
            listDevicesProcess.running = true;
        }
    }

    // Process: Disconnect from device
    Process {
        id: disconnectDeviceProcess

        onExited: (exitCode, exitStatus) => {
            // Refresh device list after disconnection
            listDevicesProcess.running = true;
        }
    }

    // Process: Pair with device
    Process {
        id: pairDeviceProcess

        onExited: (exitCode, exitStatus) => {
            // Refresh device list after pairing
            listDevicesProcess.running = true;
        }
    }

    // Process: Remove device
    Process {
        id: removeDeviceProcess

        onExited: (exitCode, exitStatus) => {
            // Refresh device list after removal
            listDevicesProcess.running = true;
        }
    }

    // Process: Scan for devices
    Process {
        id: scanProcess

        command: ["bluetoothctl", "scan", "on"]
        onExited: (exitCode, exitStatus) => {
            listDevicesProcess.running = true;
        }
    }

    // Process: Stop scanning
    Process {
        id: scanStopProcess

        command: ["bluetoothctl", "scan", "off"]
        onExited: (exitCode, exitStatus) => {
            listDevicesProcess.running = true;
        }
    }

    // Timer to periodically refresh Bluetooth status
    Timer {
        interval: 5000  // Refresh every 5 seconds
        running: true
        repeat: true
        onTriggered: {
            refreshStatus();
            listDevicesProcess.running = true;
        }
    }
}
