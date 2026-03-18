import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Constants
import qs.Components
import qs.Services
import qs.Modules.Popups

Item {
    id: root

    implicitWidth: pill.implicitWidth
    implicitHeight: Theme.panelHeight

    readonly property bool btEnabled: BluetoothService.bluetoothEnabled
    readonly property bool btConnected: BluetoothService.hasConnectedDevices

    Rectangle {
        id: pill

        implicitWidth: row.implicitWidth + 20
        implicitHeight: Theme.blockHeight
        radius: height / 2
        anchors.centerIn: parent

        color: hoverArea.containsMouse ? Qt.rgba(Colors.on_surface_variant.r, Colors.on_surface_variant.g, Colors.on_surface_variant.b, 0.6) : Qt.rgba(Colors.on_surface_variant.r, Colors.on_surface_variant.g, Colors.on_surface_variant.b, 0.33)

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: AudioService.muted ? Icons.volumeMute : AudioService.volume > 0.6 ? Icons.volumeUp : AudioService.volume > 0.0 ? Icons.volumeDown : Icons.volumeOff
                color: AudioService.muted ? Colors.error : Colors.secondary
                font.pixelSize: Fonts.h5
                font.family: Fonts.iconFont
                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
            }

            Text {
                text: btConnected ? Icons.bluetoothConnected : Icons.bluetooth
                color: btConnected ? Colors.secondary : (btEnabled ? Colors.secondary : Colors.outline)
                font.pixelSize: Fonts.h5
                font.family: Fonts.iconFont

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
            }

            Text {
                text: Icons.settings
                color: AudioService.muted ? Colors.error : Colors.secondary
                font.pixelSize: Fonts.h5
                font.family: Fonts.iconFont

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
            }
        }

        MouseArea {
            id: hoverArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: mouse => {
                if (mouse.button === Qt.RightButton)
                    AudioService.toggleMute();
                else
                    settingsLoader.item.visible = !settingsLoader.item.visible;
            }
            onWheel: wheel => {
                if (wheel.angleDelta.y > 0)
                    AudioService.incrementVolume();
                else
                    AudioService.decrementVolume();
            }
        }
    }

    LazyLoader {
        id: settingsLoader
        loading: true

        SettingsPopup {
            anchor.window: root.QsWindow.window
            anchor.rect.x: root.QsWindow.window ? root.QsWindow.window.width - implicitWidth - 8 : 0
            anchor.rect.y: root.QsWindow.window ? root.QsWindow.window.height + 8 : 0
        }
    }
}
