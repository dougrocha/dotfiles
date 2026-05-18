import QtQuick
import Quickshell
import Quickshell.Io
import qs.Constants
import qs.Components
import qs.Services

Item {
    id: root
    implicitWidth: icon.implicitWidth
    implicitHeight: Theme.topBarHeight

    Text {
        id: icon
        anchors.centerIn: parent
        text: BluetoothService.hasConnectedDevices ? PhosphorIcons.bluetoothConnected : (BluetoothService.bluetoothEnabled ? PhosphorIcons.bluetooth : PhosphorIcons.bluetoothSlash)
        color: BluetoothService.hasConnectedDevices ? Colors.primary : Colors.on_surface_variant
        font.pixelSize: 16
        font.family: Fonts.phosphorFont
        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    HoverHandler {
        id: hover
    }

    TapHandler {
        cursorShape: Qt.PointingHandCursor
        onTapped: proc.running = true
    }

    Tooltip {
        targetItem: root
        text: BluetoothService.hasConnectedDevices ? "Bluetooth · Connected" : (BluetoothService.bluetoothEnabled ? "Bluetooth · On" : "Bluetooth · Off")
        hovered: hover.hovered
    }

    Process {
        id: proc
        command: ["launch-or-focus-tui", "bluetui"]
    }
}
