import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import qs.Components
import qs.Constants
import qs.Services

PopupWindow {
    id: panel

    color: "transparent"

    implicitWidth: card.cardWidth
    implicitHeight: card.height

    mask: Region {
        item: card
    }

    visible: Visibilities.bluetoothPanel

    PopupGrab {
        popup: panel
        onDismissed: Visibilities.bluetoothPanel = false
    }

    // Stop scanning when the panel closes; pending actions live in the service.
    onVisibleChanged: {
        if (!visible && BluetoothService.adapter)
            BluetoothService.adapter.discovering = false;
    }

    // Re-assert discovery while the panel is open; it times out on its own.
    Timer {
        id: discoveryRetry
        interval: 1000
        repeat: true
        triggeredOnStart: true
        running: panel.visible && BluetoothService.adapterPowered && !(BluetoothService.adapter?.discovering ?? true)
        onTriggered: BluetoothService.adapter.discovering = true
    }

    component Toggle: Rectangle {
        id: toggle

        property bool checked: false

        signal tapped

        width: 34
        height: 18
        radius: height / 2
        color: checked ? Colors.primary : Colors.surface_container_high
        border.color: checked ? Colors.primary : Colors.outline
        border.width: 1

        Behavior on color {
            ColorAnimation {
                duration: Theme.animations.fast
            }
        }
        Behavior on border.color {
            ColorAnimation {
                duration: Theme.animations.fast
            }
        }

        Rectangle {
            width: 12
            height: 12
            radius: width / 2
            y: (parent.height - height) / 2
            x: toggle.checked ? toggle.width - width - 3 : 3
            color: toggle.checked ? Colors.on_primary : Colors.outline

            Behavior on x {
                NumberAnimation {
                    duration: Theme.animations.fast
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on color {
                ColorAnimation {
                    duration: Theme.animations.fast
                }
            }
        }

        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler {
            onTapped: toggle.tapped()
        }
    }

    component DeviceEntry: Rectangle {
        id: entry

        required property var row

        readonly property string action: BluetoothService.pendingAction(row.address)
        // Row hover plus the forget button's own hover.
        readonly property bool hovered: rowMouse.containsMouse || forgetMouse.containsMouse
        readonly property string statusText: {
            if (action === "forgetting")
                return "Forgetting…";
            if (action === "disconnecting" || row.state === BluetoothDeviceState.Disconnecting)
                return "Disconnecting…";
            if (action === "pairing")
                return "Pairing…";
            if (action === "connecting" || row.state === BluetoothDeviceState.Connecting)
                return "Connecting…";
            if (row.connected)
                return BluetoothService.batteryLabel(row.address) || "Connected";
            return "";
        }

        width: parent.width
        height: 40
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
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: entry.row.icon
            color: entry.row.connected ? Colors.primary : Colors.on_surface_variant
            font.pixelSize: Fonts.h5
            font.family: Fonts.phosphorFont

            Behavior on color {
                ColorAnimation {
                    duration: Theme.animations.fast
                }
            }
        }

        Column {
            anchors.left: entryIcon.right
            anchors.leftMargin: 10
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
            anchors.rightMargin: 8
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

    PopupCard {
        id: card

        readonly property int cardWidth: 300

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        shown: Visibilities.bluetoothPanel
        onDismissed: Visibilities.bluetoothPanel = false

        Item {
            width: parent.width
            height: 34

            Text {
                id: heroIcon
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: BluetoothService.hasConnectedDevices ? PhosphorIcons.bluetoothConnected : (BluetoothService.bluetoothEnabled ? PhosphorIcons.bluetooth : PhosphorIcons.bluetoothSlash)
                color: BluetoothService.bluetoothEnabled ? Colors.primary : Colors.on_surface_variant
                font.pixelSize: Fonts.h2
                font.family: Fonts.phosphorFont

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animations.fast
                    }
                }
            }

            Column {
                anchors.left: heroIcon.right
                anchors.leftMargin: 12
                anchors.right: powerToggle.left
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                Text {
                    width: parent.width
                    text: "Bluetooth"
                    color: Colors.on_surface
                    font.pixelSize: Fonts.h4
                    font.family: Fonts.font
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    text: BluetoothService.statusText
                    color: Colors.on_surface_variant
                    font.pixelSize: Fonts.caption
                    font.family: Fonts.font
                    elide: Text.ElideRight
                }
            }

            Toggle {
                id: powerToggle
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                checked: BluetoothService.bluetoothEnabled
                onTapped: BluetoothService.togglePower()
            }
        }

        Column {
            width: parent.width
            spacing: Theme.popup.spacing
            visible: BluetoothService.connectedRows.length > 0

            PopupDivider {}

            SectionLabel {
                text: "CONNECTED"
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
            spacing: Theme.popup.spacing
            visible: BluetoothService.pairedRows.length > 0 || BluetoothService.discoveredRows.length > 0

            PopupDivider {}

            // Capped so a busy room can't run the card off-screen.
            Flickable {
                width: parent.width
                height: Math.min(scrollContent.implicitHeight, 240)
                contentHeight: scrollContent.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                interactive: contentHeight > height

                Column {
                    id: scrollContent
                    width: parent.width
                    spacing: Theme.popup.spacing

                    Column {
                        width: parent.width
                        spacing: Theme.popup.spacing
                        visible: BluetoothService.pairedRows.length > 0

                        SectionLabel {
                            text: "PAIRED"
                        }

                        Column {
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

                    Column {
                        width: parent.width
                        spacing: Theme.popup.spacing
                        visible: BluetoothService.discoveredRows.length > 0

                        SectionLabel {
                            text: "AVAILABLE"
                        }

                        Column {
                            width: parent.width
                            spacing: 2

                            Repeater {
                                model: ScriptModel {
                                    values: BluetoothService.discoveredRows
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
            }
        }

        Text {
            visible: BluetoothService.connectedRows.length === 0 && BluetoothService.pairedRows.length === 0 && BluetoothService.discoveredRows.length === 0
            width: parent.width
            text: {
                if (!BluetoothService.adapter)
                    return "No Bluetooth adapter";
                if (!BluetoothService.bluetoothEnabled)
                    return "Turn Bluetooth on to scan";
                return "Scanning for devices…";
            }
            color: Colors.on_surface_variant
            font.pixelSize: Fonts.body.size
            font.family: Fonts.font
            wrapMode: Text.WordWrap
        }

        PopupDivider {}

        PopupActionButton {
            label: "Bluetooth Settings…"
            onTapped: {
                Visibilities.bluetoothPanel = false;
                bluetoothSettingsProc.running = true;
            }
        }

        Process {
            id: bluetoothSettingsProc
            command: ["launch-or-focus-tui", "bluetui"]
        }
    }
}
