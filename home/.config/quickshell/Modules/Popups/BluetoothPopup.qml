import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import qs.Components
import qs.Constants
import qs.Services

Popup {
    id: panel

    shown: Visibilities.bluetoothPanel
    onDismissed: Visibilities.bluetoothPanel = false

    component DeviceEntry: Rectangle {
        id: entry

        required property var row

        readonly property string action: BluetoothService.pendingAction(row.address)
        // Row hover plus the forget button's own hover.
        readonly property bool hovered: rowMouse.containsMouse || forgetMouse.containsMouse
        readonly property string statusText: {
            if (action === "forgetting")
                return "Forgetting";
            if (action === "disconnecting" || row.state === BluetoothDeviceState.Disconnecting)
                return "Disconnecting";
            if (action === "pairing")
                return "Pairing";
            if (action === "connecting" || row.state === BluetoothDeviceState.Connecting)
                return "Connecting";
            if (row.connected)
                return BluetoothService.batteryLabel(row.address) || "Connected";
            return "";
        }

        width: parent.width
        height: 34
        radius: Theme.blockRadius
        // Animate to the card's own colour, not "transparent", or the fill flashes dark.
        color: entry.hovered ? Colors.surface_container_high : Colors.surface_container

        Behavior on color {
            ColorAnimation {
                duration: Theme.animations.fast
            }
        }

        // Declared first so it sits beneath the forget button.
        MouseArea {
            id: rowMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: BluetoothService.activate(entry.row)
        }

        Text {
            id: entryIcon
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            text: entry.row.icon
            color: entry.row.connected ? Colors.primary : Colors.on_surface_variant
            font.pixelSize: 15
            font.family: Fonts.phosphorFont

            Behavior on color {
                ColorAnimation {
                    duration: Theme.animations.fast
                }
            }
        }

        Column {
            anchors.left: entryIcon.right
            anchors.leftMargin: 8
            anchors.right: forgetButton.left
            anchors.rightMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1

            Text {
                width: parent.width
                text: entry.row.label
                color: entry.row.connected ? Colors.on_surface : Colors.on_surface_variant
                font.pixelSize: Fonts.body.size
                font.family: Fonts.font
                font.weight: entry.row.connected ? Font.Medium : Font.Normal
                elide: Text.ElideRight
            }

            Text {
                visible: entry.statusText !== ""
                width: parent.width
                text: entry.statusText
                color: entry.row.connected ? Colors.primary : Colors.on_surface_variant
                font.pixelSize: Fonts.caption
                font.family: Fonts.font
                elide: Text.ElideRight
            }
        }

        Rectangle {
            id: forgetButton

            visible: entry.row.known && entry.hovered

            anchors.right: parent.right
            anchors.rightMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            width: 22
            height: 22
            radius: width / 2
            color: forgetMouse.containsMouse ? Colors.surface_container_highest : Colors.surface_container_high

            Behavior on color {
                ColorAnimation {
                    duration: Theme.animations.fast
                }
            }

            Text {
                anchors.centerIn: parent
                text: PhosphorIcons.x
                color: forgetMouse.containsMouse ? Colors.error : Colors.on_surface_variant
                font.pixelSize: Fonts.body.size
                font.family: Fonts.phosphorFont

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animations.fast
                    }
                }
            }

            // Child MouseArea so a forget click doesn't also toggle the connection.
            MouseArea {
                id: forgetMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: BluetoothService.forget(entry.row)
            }
        }
    }

    Column {
        width: parent.width
        spacing: 6

        Item {
            width: parent.width
            height: 24

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "Bluetooth"
                color: Colors.on_surface
                font.pixelSize: 16
                font.weight: Font.Medium
                font.family: Fonts.font
            }
        }

        Rectangle {
            id: powerRow

            readonly property bool active: BluetoothService.bluetoothEnabled

            width: parent.width
            height: 34
            radius: Theme.blockRadius
            activeFocusOnTab: true
            color: active ? Colors.primary : (powerHover.hovered || activeFocus ? Colors.surface_container_high : Colors.surface_container)

            Behavior on color {
                ColorAnimation {
                    duration: Theme.animations.fast
                }
            }

            Text {
                id: powerIcon
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: BluetoothService.hasConnectedDevices ? PhosphorIcons.bluetoothConnected : (powerRow.active ? PhosphorIcons.bluetooth : PhosphorIcons.bluetoothSlash)
                color: powerRow.active ? Colors.on_primary : Colors.on_surface_variant
                font.pixelSize: 15
                font.family: Fonts.phosphorFont

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animations.fast
                    }
                }
            }

            Text {
                anchors.left: powerIcon.right
                anchors.leftMargin: 8
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: BluetoothService.statusText.replace(/^Bluetooth\s+/, "")
                color: powerRow.active ? Colors.on_primary : Colors.on_surface
                font.pixelSize: Fonts.body.size
                font.family: Fonts.font
                elide: Text.ElideRight

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animations.fast
                    }
                }
            }

            HoverHandler {
                id: powerHover
                cursorShape: Qt.PointingHandCursor
            }
            TapHandler {
                onTapped: BluetoothService.togglePower()
            }
            Keys.onPressed: function (event) {
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                    BluetoothService.togglePower();
                    event.accepted = true;
                }
            }
        }

        Column {
            width: parent.width
            spacing: 6
            visible: BluetoothService.connectedRows.length > 0

            Item {
                width: parent.width
                height: 4
            }

            Text {
                text: "Connected"
                color: Colors.on_surface_variant
                font.pixelSize: Fonts.caption
                font.weight: Font.Medium
                font.family: Fonts.font
            }

            Column {
                width: parent.width
                spacing: 2

                Repeater {
                    model: ScriptModel {
                        values: BluetoothService.connectedRows
                        objectProp: "address"
                    }

                    delegate: DeviceEntry {
                        required property var modelData
                        row: modelData
                    }
                }
            }
        }

        Column {
            width: parent.width
            spacing: 6
            visible: BluetoothService.pairedRows.length > 0

            Divider {
                visible: BluetoothService.connectedRows.length > 0
            }

            Item {
                width: parent.width
                height: 4
                visible: BluetoothService.connectedRows.length === 0
            }

            Text {
                text: "Paired"
                color: Colors.on_surface
                font.pixelSize: Fonts.body.size
                font.weight: Font.Medium
                font.family: Fonts.font
            }

            // Capped so a busy room can't run the card off-screen.
            Flickable {
                width: parent.width
                height: Math.min(pairedColumn.implicitHeight, 240)
                contentHeight: pairedColumn.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                interactive: contentHeight > height

                Column {
                    id: pairedColumn
                    width: parent.width
                    spacing: 2

                    Repeater {
                        model: ScriptModel {
                            values: BluetoothService.pairedRows
                            objectProp: "address"
                        }

                        delegate: DeviceEntry {
                            required property var modelData
                            row: modelData
                        }
                    }
                }
            }
        }

        Text {
            visible: BluetoothService.connectedRows.length === 0 && BluetoothService.pairedRows.length === 0
            width: parent.width
            text: {
                if (!BluetoothService.adapter)
                    return "No Bluetooth adapter";
                if (!BluetoothService.bluetoothEnabled)
                    return "Turn Bluetooth on";
                return "No paired devices";
            }
            color: Colors.on_surface_variant
            font.pixelSize: Fonts.body.size
            font.family: Fonts.font
            wrapMode: Text.WordWrap
        }

        PopupActionButton {
            label: "Bluetui"
            leftAlign: true
            onTapped: {
                Visibilities.bluetoothPanel = false;
                bluetoothSettingsProc.running = true;
            }
        }
    }

    Process {
        id: bluetoothSettingsProc
        command: ["launch-or-focus-tui", "bluetui"]
    }
}
