import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.Constants
import qs.Components
import qs.Services

PopupWindow {
    id: settingsPanel

    onVisibleChanged: {
        if (visible) {
            IdleService.refresh();
            SunsetService.refresh();
        }
    }

    implicitWidth: 420
    implicitHeight: 500
    color: "transparent"

    HyprlandFocusGrab {
        id: focusGrab

        active: settingsPanel.visible
        windows: [settingsPanel]
        onActiveChanged: {
            if (!active && settingsPanel.visible)
                settingsPanel.visible = false;
        }
    }

    Rectangle {
        id: contentRect

        anchors.fill: parent
        color: Colors.surface_container
        radius: 12
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Header
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "Settings"
                color: Colors.primary
                font.pixelSize: 24
                font.family: Fonts.font
                font.bold: true
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                text: Icons.closeSmall
                color: Colors.primary
                font.family: Fonts.iconFont
                font.pixelSize: 28

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: settingsPanel.visible = false
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Colors.outline_variant
        }

        // Speakers Section
        RowLayout {
            Layout.fillWidth: true
            spacing: 15

            Text {
                text: Icons.speaker
                color: Colors.primary
                font.pixelSize: 20
                font.family: Fonts.iconFont
            }

            Text {
                text: "Speakers"
                color: Colors.on_surface_variant
                font.pixelSize: 14
                font.family: Fonts.font
                Layout.preferredWidth: 100
            }

            Slider {
                id: volumeSliders

                Layout.preferredWidth: 120
                from: 0
                to: 1.5
                value: AudioService.volume
                onMoved: {
                    AudioService.setVolume(value);
                }

                background: Rectangle {
                    x: volumeSliders.leftPadding
                    y: volumeSliders.topPadding + volumeSliders.availableHeight / 2 - height / 2
                    width: volumeSliders.availableWidth
                    height: 4
                    radius: 2
                    color: Colors.outline_variant

                    Rectangle {
                        width: volumeSliders.visualPosition * parent.width
                        height: parent.height
                        color: Colors.primary
                        radius: 2

                        Behavior on width {
                            NumberAnimation {
                                duration: 100
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }

                handle: Rectangle {
                    x: volumeSliders.leftPadding + volumeSliders.visualPosition * (volumeSliders.availableWidth - width)
                    y: volumeSliders.topPadding + volumeSliders.availableHeight / 2 - height / 2
                    implicitWidth: 14
                    implicitHeight: 14
                    radius: 7
                    color: volumeSliders.pressed ? Colors.primary_fixed : Colors.primary

                    Behavior on x {
                        NumberAnimation {
                            duration: 100
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }

            Text {
                text: Math.round(AudioService.volume * 100) + "%"
                color: Colors.on_surface_variant
                font.pixelSize: 14
                font.family: Fonts.font
                Layout.preferredWidth: 45
            }

            Text {
                text: AudioService.muted ? Icons.volumeMute : Icons.volumeUp
                color: Colors.primary
                font.pixelSize: 20
                font.family: Fonts.iconFont

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: AudioService.toggleMute()
                }
            }
        }

        // Microphone Section
        RowLayout {
            Layout.fillWidth: true
            spacing: 15

            Text {
                text: Icons.mic
                color: Colors.primary
                font.pixelSize: 20
                font.family: Fonts.iconFont
            }

            Text {
                text: "Microphone"
                color: Colors.on_surface_variant
                font.pixelSize: 14
                font.family: Fonts.font
                Layout.preferredWidth: 100
            }

            Slider {
                id: micSlider

                Layout.preferredWidth: 120
                from: 0
                to: 1.5
                value: AudioService.sourceVolume
                onMoved: {
                    AudioService.setSourceVolumeValue(value);
                }

                background: Rectangle {
                    x: micSlider.leftPadding
                    y: micSlider.topPadding + micSlider.availableHeight / 2 - height / 2
                    width: micSlider.availableWidth
                    height: 4
                    radius: 2
                    color: Colors.outline_variant

                    Rectangle {
                        width: micSlider.visualPosition * parent.width
                        height: parent.height
                        color: Colors.primary
                        radius: 2
                    }
                }

                handle: Rectangle {
                    x: micSlider.leftPadding + micSlider.visualPosition * (micSlider.availableWidth - width)
                    y: micSlider.topPadding + micSlider.availableHeight / 2 - height / 2
                    implicitWidth: 14
                    implicitHeight: 14
                    radius: 7
                    color: micSlider.pressed ? Colors.primary_fixed : Colors.primary

                    Behavior on x {
                        NumberAnimation {
                            duration: 100
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }

            Text {
                text: Math.round(AudioService.sourceVolume * 100) + "%"
                color: Colors.on_surface_variant
                font.pixelSize: 14
                font.family: Fonts.font
                Layout.preferredWidth: 45
            }

            Text {
                text: AudioService.sourceMuted ? Icons.micOff : Icons.mic
                color: Colors.primary
                font.pixelSize: 20
                font.family: Fonts.iconFont

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: AudioService.toggleSourceMute()
                }
            }
        }

        // Utility Buttons Row
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            // Toggle Idle Button
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                color: toggleIdleButton.containsMouse ? Colors.surface_container_high : "transparent"
                radius: 8

                Text {
                    anchors.centerIn: parent
                    text: Icons.lockClock
                    color: IdleService.active ? Colors.tertiary : Colors.outline
                    font.pixelSize: 18
                    font.family: Fonts.iconFont
                }

                MouseArea {
                    id: toggleIdleButton

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: IdleService.toggle()
                }
            }

            // Switch Audio Button
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                color: switchAudioButton.containsMouse ? Colors.surface_container_high : "transparent"
                radius: 8

                Text {
                    anchors.centerIn: parent
                    text: Icons.speaker
                    color: Colors.primary
                    font.pixelSize: 18
                    font.family: Fonts.iconFont
                }

                MouseArea {
                    id: switchAudioButton

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        switchAudioProcess.running = true;
                        settingsPanel.visible = false;
                    }
                }
            }

            // Bluetooth Button
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                color: bluetoothButton.containsMouse ? Colors.surface_container_high : "transparent"
                radius: 8

                Text {
                    anchors.centerIn: parent
                    text: Icons.settingsBluetooth
                    color: BluetoothService.bluetoothEnabled ? (BluetoothService.hasConnectedDevices ? Colors.tertiary : Colors.secondary) : Colors.outline
                    font.pixelSize: 18
                    font.family: Fonts.iconFont
                }

                MouseArea {
                    id: bluetoothButton

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        bluetoothProcess.running = true;
                        settingsPanel.visible = false;
                    }
                }
            }

            // Hyprsunset Toggle Button
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                color: sunsetButton.containsMouse ? Colors.surface_container_high : "transparent"
                radius: 8

                Text {
                    anchors.centerIn: parent
                    text: SunsetService.active ? Icons.wbSunny : Icons.nightlight
                    color: SunsetService.active ? Colors.tertiary_container : Colors.outline
                    font.pixelSize: 18
                    font.family: Fonts.iconFont
                }

                MouseArea {
                    id: sunsetButton

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: SunsetService.toggle()
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Colors.outline_variant
        }

        // Power Buttons Row
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            // Shutdown Button
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                color: shutdownButton.containsMouse ? Colors.surface_container_high : "transparent"
                radius: 8

                Text {
                    text: Icons.powerSettingsNew
                    color: Colors.error
                    font.pixelSize: 24
                    font.family: Fonts.iconFont
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: shutdownButton

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: shutdownProcess.running = true
                }
            }

            // Reboot Button
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                color: rebootButton.containsMouse ? Colors.surface_container_high : "transparent"
                radius: 8

                Text {
                    text: Icons.restartAlt
                    color: Colors.tertiary
                    font.pixelSize: 24
                    font.family: Fonts.iconFont
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: rebootButton

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: rebootProcess.running = true
                }
            }

            // Logout Button
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                color: logoutButton.containsMouse ? Colors.surface_container_high : "transparent"
                radius: 8

                Text {
                    text: Icons.logout
                    color: Colors.primary
                    font.pixelSize: 24
                    font.family: Fonts.iconFont
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: logoutButton

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: logoutProcess.running = true
                }
            }
        }
    }

    Process {
        id: switchAudioProcess
        command: ["launch-or-focus-tui", "switch-audio"]
    }

    Process {
        id: bluetoothProcess
        command: ["launch-or-focus-tui", "bluetui"]
    }

    Process {
        id: shutdownProcess
        command: ["sh", "-c", "hyprctl dispatch exec \"hyprshutdown -t 'Shutting down...' --post-cmd 'shutdown -P 0'\""]
    }

    Process {
        id: rebootProcess
        command: ["sh", "-c", "hyprctl dispatch exec \"hyprshutdown -t 'Restarting...' --post-cmd 'systemctl reboot'\""]
    }

    Process {
        id: logoutProcess
        command: ["sh", "-c", "hyprctl dispatch exec \"hyprshutdown -t 'Logging out...'\""]
    }

    mask: Region {
        item: contentRect
    }
}
