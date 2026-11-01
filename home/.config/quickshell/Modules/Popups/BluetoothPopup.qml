import QtQuick
import qs.Components
import qs.Services

Popup {
    panelName: Visibilities.names.bluetooth

    BluetoothPanel {
        width: parent.width
    }
}
