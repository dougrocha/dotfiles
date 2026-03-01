import "./Services"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Item {
    id: root

    property color iconColor
    property int iconSize
    property string fontFamily

    implicitWidth: settingsIcon.implicitWidth
    implicitHeight: settingsIcon.implicitHeight

    Text {
        id: settingsIcon

        text: "󰒓" // Settings gear icon
        color: root.iconColor
        font.pixelSize: root.iconSize
        font.family: root.fontFamily
        font.bold: true

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                // Load the panel if not already loaded
                if (!settingPanelPopupLoader.loading)
                    settingPanelPopupLoader.loading = true;

                // Toggle visibility once loaded
                if (settingPanelPopupLoader.item)
                    settingPanelPopupLoader.item.visible = !settingPanelPopupLoader.item.visible;

            }
        }

    }

    LazyLoader {
        id: settingPanelPopupLoader

        loading: false

        PanelWindow {
            id: settingsPanel

            visible: false
            implicitWidth: 420
            implicitHeight: 500
            color: "transparent"

            anchors {
                top: true
                right: true
            }

            margins {
                top: 8
                right: 8
            }

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
                color: "#2b1f1a"
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
                        color: "#d4a574"
                        font.pixelSize: 24
                        font.family: "JetBrainsMono Nerd Font"
                        font.bold: true
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "×"
                        color: "#d4a574"
                        font.pixelSize: 28

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: settingsPanel.visible = false
                        }

                    }

                }

                // User Profile
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    Rectangle {
                        width: 64
                        height: 64
                        radius: 32
                        color: "transparent"
                        clip: true

                        Image {
                            anchors.fill: parent
                            source: "file:///home/doug/.config/user-img.jpg"
                            fillMode: Image.PreserveAspectCrop
                        }

                    }

                    Text {
                        text: "doug"
                        color: "#d4a574"
                        font.pixelSize: 18
                        font.family: "JetBrainsMono Nerd Font"
                    }

                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#3d3027"
                }

                // Speakers Section
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    Text {
                        text: "󰓃"
                        color: "#d4a574"
                        font.pixelSize: 20
                        font.family: "JetBrainsMono Nerd Font"
                    }

                    Text {
                        text: "Speakers"
                        color: "#8b7a6a"
                        font.pixelSize: 14
                        font.family: "JetBrainsMono Nerd Font"
                        Layout.preferredWidth: 100
                    }

                    Slider {
                        id: volumeSliders

                        Layout.fillWidth: true
                        from: 0
                        to: 150
                        value: AudioService.sinkVolume
                        onMoved: {
                            AudioService.setSinkVolume(value);
                        }

                        background: Rectangle {
                            x: volumeSliders.leftPadding
                            y: volumeSliders.topPadding + volumeSliders.availableHeight / 2 - height / 2
                            width: volumeSliders.availableWidth
                            height: 4
                            radius: 2
                            color: "#3d3027"

                            Rectangle {
                                width: volumeSliders.visualPosition * parent.width
                                height: parent.height
                                color: "#d4a574"
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
                            color: volumeSliders.pressed ? "#e8c89a" : "#d4a574"

                            Behavior on x {
                                NumberAnimation {
                                    duration: 100
                                    easing.type: Easing.OutCubic
                                }

                            }

                        }

                    }

                    Text {
                        text: Math.round(AudioService.sinkVolume) + "%"
                        color: "#8b7a6a"
                        font.pixelSize: 14
                        font.family: "JetBrainsMono Nerd Font"
                        Layout.preferredWidth: 45
                    }

                    Text {
                        text: AudioService.sinkMuted ? "󰖁" : "󰕾"
                        color: "#d4a574"
                        font.pixelSize: 20
                        font.family: "JetBrainsMono Nerd Font"

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: AudioService.toggleSinkMute()
                        }

                    }

                }

                // Microphone Section
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    Text {
                        text: "󰍬"
                        color: "#d4a574"
                        font.pixelSize: 20
                        font.family: "JetBrainsMono Nerd Font"
                    }

                    Text {
                        text: "Microphone"
                        color: "#8b7a6a"
                        font.pixelSize: 14
                        font.family: "JetBrainsMono Nerd Font"
                        Layout.preferredWidth: 100
                    }

                    Slider {
                        id: micSlider

                        Layout.fillWidth: true
                        from: 0
                        to: 100
                        value: AudioService.sourceVolume
                        onMoved: {
                            AudioService.setSourceVolume(value);
                        }

                        background: Rectangle {
                            x: micSlider.leftPadding
                            y: micSlider.topPadding + micSlider.availableHeight / 2 - height / 2
                            width: micSlider.availableWidth
                            height: 4
                            radius: 2
                            color: "#3d3027"

                            Rectangle {
                                width: micSlider.visualPosition * parent.width
                                height: parent.height
                                color: "#d4a574"
                                radius: 2
                            }

                        }

                        handle: Rectangle {
                            x: micSlider.leftPadding + micSlider.visualPosition * (micSlider.availableWidth - width)
                            y: micSlider.topPadding + micSlider.availableHeight / 2 - height / 2
                            implicitWidth: 14
                            implicitHeight: 14
                            radius: 7
                            color: micSlider.pressed ? "#e8c89a" : "#d4a574"

                            Behavior on x {
                                NumberAnimation {
                                    duration: 100
                                    easing.type: Easing.OutCubic
                                }

                            }

                        }

                    }

                    Text {
                        text: Math.round(AudioService.sourceVolume) + "%"
                        color: "#8b7a6a"
                        font.pixelSize: 14
                        font.family: "JetBrainsMono Nerd Font"
                        Layout.preferredWidth: 45
                    }

                    Text {
                        text: AudioService.sourceMuted ? "󰍭" : "󰍬"
                        color: "#d4a574"
                        font.pixelSize: 20
                        font.family: "JetBrainsMono Nerd Font"

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: AudioService.toggleSourceMute()
                        }

                    }

                }

                Item {
                    Layout.fillHeight: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#3d3027"
                }

                // Power Buttons Row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    // Shutdown Button
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        color: shutdownButton.containsMouse ? "#3d3027" : "transparent"
                        radius: 8

                        Text {
                            text: "⏻"
                            color: "#f7768e"
                            font.pixelSize: 24
                            font.family: "JetBrainsMono Nerd Font"
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            id: shutdownButton

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                shutdownProcess.running = true;
                            }
                        }

                    }

                    // Reboot Button
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        color: rebootButton.containsMouse ? "#3d3027" : "transparent"
                        radius: 8

                        Text {
                            text: "󰜉"
                            color: "#e0af68"
                            font.pixelSize: 24
                            font.family: "JetBrainsMono Nerd Font"
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            id: rebootButton

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                rebootProcess.running = true;
                            }
                        }

                    }

                    // Logout Button
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        color: logoutButton.containsMouse ? "#3d3027" : "transparent"
                        radius: 8

                        Text {
                            text: "󰍃"
                            color: "#7aa2f7"
                            font.pixelSize: 24
                            font.family: "JetBrainsMono Nerd Font"
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            id: logoutButton

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                logoutProcess.running = true;
                            }
                        }

                    }

                }

            }

            Process {
                id: shutdownProcess

                running: false
                command: ["sh", "-c", "nohup hyprshutdown -t 'Shutting Down...' --post-cmd 'shutdown -P 0' &"]
            }

            Process {
                id: rebootProcess

                running: false
                command: ["sh", "-c", "nohup hyprshutdown -t 'Rebooting...' --post-cmd 'reboot' &"]
            }

            Process {
                id: logoutProcess

                running: false
                command: ["sh", "-c", "nohup hyprshutdown -t 'Logging out...' &"]
            }

            mask: Region {
                item: contentRect
            }

        }

    }

}
