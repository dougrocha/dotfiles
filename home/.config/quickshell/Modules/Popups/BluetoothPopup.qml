pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.Components
import qs.Constants
import qs.Services

Popup {
    id: panel

    panelName: "bluetooth-panel"
    cardWidth: 300

    component DeviceEntry: PanelRow {
        id: entry

        required property var device

        readonly property string statusText: BluetoothService.rowStatus(device)

        onTapped: BluetoothService.activate(device)

        Text {
            id: entryIcon
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: entry.device.icon
            color: entry.device.connected ? Theme.accent : Theme.text.secondary
            font.pixelSize: Theme.icon.sm
            font.family: Theme.font.icon

            Behavior on color {
                ColorAnimation {
                    duration: Theme.motion.fast
                }
            }
        }

        Column {
            anchors.left: entryIcon.right
            anchors.leftMargin: 10
            anchors.right: forgetButton.left
            anchors.rightMargin: Theme.space.sm
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.space.xxs

            Text {
                width: parent.width
                text: entry.device.label
                color: entry.device.connected ? Theme.text.primary : Theme.text.secondary
                font.pixelSize: Theme.type.body.size
                font.family: Theme.font.ui
                font.weight: entry.device.connected ? Theme.type.title.weight : Theme.type.body.weight
                elide: Text.ElideRight
            }

            Text {
                visible: entry.statusText !== ""
                width: parent.width
                text: entry.statusText
                color: entry.device.connected ? Theme.accent : Theme.text.secondary
                font.pixelSize: Theme.type.caption.size
                font.family: Theme.font.ui
                elide: Text.ElideRight
            }
        }

        IconActionButton {
            id: forgetButton
            visible: entry.device.known && entry.hovered
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            size: 22
            circular: true
            danger: true
            glyph: PhosphorIcons.x
            onTapped: BluetoothService.forget(entry.device)
        }
    }

    Column {
        width: parent.width
        spacing: Theme.space.sm

        ToggleRow {
            width: parent.width
            style: "switch"
            bleed: Theme.panel.rowBleed
            glyph: BluetoothService.glyph
            label: "Bluetooth"
            active: BluetoothService.powered
            onToggled: BluetoothService.togglePower()
        }

        Column {
            width: parent.width
            spacing: Theme.space.sm
            visible: BluetoothService.connectedRows.length > 0

            Item {
                width: parent.width
                height: 4
            }

            SectionLabel {
                text: "CONNECTED"
            }

            Column {
                width: parent.width
                spacing: Theme.space.xxs

                Repeater {
                    model: ScriptModel {
                        values: BluetoothService.connectedRows
                        objectProp: "address"
                    }

                    delegate: DeviceEntry {
                        required property var modelData
                        device: modelData
                    }
                }
            }
        }

        Column {
            width: parent.width
            spacing: Theme.space.sm
            visible: BluetoothService.pairedRows.length > 0

            Item {
                width: parent.width
                height: 4
            }

            SectionLabel {
                text: "PAIRED"
            }

            Flickable {
                id: pairedScroll
                x: -Theme.panel.rowBleed
                width: parent.width + Theme.panel.rowBleed * 2
                height: Math.min(pairedColumn.implicitHeight, 240)
                contentHeight: pairedColumn.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                interactive: contentHeight > height

                Column {
                    id: pairedColumn
                    x: Theme.panel.rowBleed
                    width: pairedScroll.width - Theme.panel.rowBleed * 2
                    spacing: Theme.space.xxs

                    Repeater {
                        model: ScriptModel {
                            values: BluetoothService.pairedRows
                            objectProp: "address"
                        }

                        delegate: DeviceEntry {
                            required property var modelData
                            device: modelData
                        }
                    }
                }
            }
        }

        Text {
            visible: BluetoothService.connectedRows.length === 0 && BluetoothService.pairedRows.length === 0
            width: parent.width
            text: {
                if (!BluetoothService.available)
                    return "No Bluetooth adapter";
                if (!BluetoothService.powered)
                    return "Turn Bluetooth on";
                return "No paired devices";
            }
            color: Theme.text.secondary
            font.pixelSize: Theme.type.body.size
            font.family: Theme.font.ui
            wrapMode: Text.WordWrap
        }

        Divider {}

        PopupActionButton {
            label: "Bluetui"
            onTapped: {
                panel.close();
                Quickshell.execDetached(["launch-or-focus-tui", "bluetui"]);
            }
        }
    }
}
