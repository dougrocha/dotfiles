import "../../Services"
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

PopupWindow {
    id: root

    property Item anchorItem

    function formatTime(seconds) {
        if (!seconds || seconds < 0)
            return "0:00";

        let mins = Math.floor(seconds / 60);
        let secs = Math.floor(seconds % 60);
        return mins + ":" + (secs < 10 ? "0" : "") + secs;
    }

    implicitHeight: 160
    implicitWidth: 400
    color: "transparent"
    visible: false

    anchor {
        item: root.anchorItem
        edges: Edges.Bottom | Edges.HCenter
        gravity: Edges.Bottom | Edges.HCenter
        margins.top: 36
    }

    HyprlandFocusGrab {
        id: focusGrab

        active: root.visible
        windows: [root]
        onActiveChanged: {
            if (!active && root.visible)
                root.visible = false;

        }
    }

    Rectangle {
        id: background

        anchors.fill: parent
        radius: 12
        color: "#141313"
        border.width: 1
        border.color: "#202020"
        layer.enabled: true

        Image {
            id: backgroundImage

            anchors.fill: parent
            source: CiderRpcService.trackArtUrl || ""
            fillMode: Image.PreserveAspectCrop
            layer.enabled: true

            layer.effect: MultiEffect {
                blurEnabled: true
                blurMax: 32
                blur: 1
            }

        }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.45)
            visible: backgroundImage.status === Image.Ready
        }

        RowLayout {
            id: contentLayout

            anchors.centerIn: parent
            width: parent.width - 24 // TODO: Add padding
            spacing: 24

            Rectangle {
                id: coverArtContainer

                Layout.preferredWidth: 140
                Layout.preferredHeight: 140
                Layout.alignment: Qt.AlignVCenter
                radius: 12
                color: "#131314"
                layer.enabled: true

                Rectangle {
                    id: coverMask

                    width: coverArtContainer.width
                    height: coverArtContainer.height
                    radius: coverArtContainer.radius
                    visible: false
                }

                Image {
                    id: coverArt

                    anchors.fill: parent
                    source: CiderRpcService.trackArtUrl || ""
                    fillMode: Image.PreserveAspectCrop
                }

                Text {
                    anchors.centerIn: parent
                    text: "󰝚"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 40
                    color: "#8b7a6a"
                    visible: coverArt.status !== Image.Ready
                }

                layer.effect: MultiEffect {
                    maskEnabled: true

                    maskSource: ShaderEffectSource {
                        sourceItem: coverMask
                        hideSource: true
                        live: false
                    }

                }

            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
                spacing: 2

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        text: CiderRpcService.trackTitle || "Unknown Title"
                        color: "#DEE2E6"
                        font.pixelSize: 20
                        font.family: "JetBrainsMono Nerd Font"
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                }

                Text {
                    Layout.fillWidth: true
                    text: CiderRpcService.trackArtist || "Unknown Artist"
                    color: "#CAC4D0"
                    font.pixelSize: 14
                    font.family: "JetBrainsMono Nerd Font"
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 8
                    spacing: 4

                    Timer {
                        id: seekDebounce

                        interval: 300
                        running: false
                    }

                    Slider {
                        id: seekSlider

                        Layout.fillWidth: true
                        from: 0
                        to: CiderRpcService.duration > 0 ? CiderRpcService.duration : 1
                        value: (pressed || seekDebounce.running) ? value : CiderRpcService.position
                        onPressedChanged: {
                            if (!pressed) {
                                MediaControlService.seek(value);
                                seekDebounce.start();
                            }
                        }

                        HoverHandler {
                            cursorShape: Qt.PointingHandCursor
                        }

                        background: Rectangle {
                            x: seekSlider.leftPadding
                            y: seekSlider.topPadding + seekSlider.availableHeight / 2 - height / 2
                            width: seekSlider.availableWidth
                            height: 6
                            radius: 8
                            color: Qt.rgba(0.79, 0.77, 0.82, 0.3)

                            Rectangle {
                                width: seekSlider.visualPosition * parent.width
                                height: parent.height
                                color: "#DEE2E6"
                                radius: 8
                            }

                        }

                        handle: Rectangle {
                            x: seekSlider.leftPadding + seekSlider.visualPosition * (seekSlider.availableWidth - width)
                            y: seekSlider.topPadding + seekSlider.availableHeight / 2 - height / 2
                            implicitHeight: 8
                            radius: 8
                            color: "transparent"
                        }

                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: (seekSlider.pressed || seekDebounce.running) ? formatTime(seekSlider.value) : formatTime(CiderRpcService.position)
                            color: "#98989f"
                            font.pixelSize: 12
                            font.family: "JetBrainsMono Nerd Font"
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: formatTime(CiderRpcService.duration)
                            color: "#98989f"
                            font.pixelSize: 12
                            font.family: "JetBrainsMono Nerd Font"
                        }

                    }

                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter
                    spacing: 8

                    Rectangle {
                        width: 32
                        height: 32
                        color: "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "󰒮"
                            color: "#fff"
                            font.pixelSize: 32
                            font.family: "JetBrainsMono Nerd Font"
                            font.bold: true
                        }

                        MouseArea {
                            id: prevMa

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: MediaControlService.previous()
                        }

                    }

                    Rectangle {
                        color: "transparent"
                        width: 48
                        height: 48

                        Text {
                            anchors.centerIn: parent
                            text: CiderRpcService.isPlaying ? "󰏤" : "󰐊"
                            color: "#fff"
                            font.pixelSize: 48
                            font.family: "JetBrainsMono Nerd Font"
                            font.bold: true
                        }

                        MouseArea {
                            id: playPauseMa

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: MediaControlService.playpause()
                        }

                    }

                    Rectangle {
                        width: 32
                        color: "transparent"
                        height: 32

                        Text {
                            anchors.centerIn: parent
                            text: "󰒭"
                            color: "#fff"
                            font.pixelSize: 32
                            font.family: "JetBrainsMono Nerd Font"
                            font.bold: true
                        }

                        MouseArea {
                            id: nextMa

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: MediaControlService.next()
                        }

                    }

                }

            }

        }

        Rectangle {
            id: maskItem

            width: background.width
            height: background.height
            radius: 12
            visible: false
        }

        layer.effect: MultiEffect {
            maskEnabled: true

            maskSource: ShaderEffectSource {
                sourceItem: maskItem
                hideSource: true
                live: false
            }

        }

    }

}
