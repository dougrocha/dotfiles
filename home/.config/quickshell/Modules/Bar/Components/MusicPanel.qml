pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import qs.Constants
import qs.Services

PopupWindow {
    id: root

    function formatTime(seconds) {
        if (!seconds || seconds < 0)
            return "0:00";
        const mins = Math.floor(seconds / 60);
        const secs = Math.floor(seconds % 60);
        return mins + ":" + (secs < 10 ? "0" : "") + secs;
    }

    implicitWidth: 480
    implicitHeight: mainLayout.implicitHeight + 28
    color: "transparent"
    grabFocus: true
    visible: false

    Rectangle {
        id: musicContent

        anchors.fill: parent
        radius: 16
        color: Colors.surface_container_low
        border.width: 1
        border.color: Colors.outline_variant
        layer.enabled: true

        scale: root.visible ? 1.0 : 0.85
        opacity: root.visible ? 1.0 : 0.0
        transformOrigin: Item.Top

        Behavior on scale {
            SpringAnimation {
                spring: 8.0
                damping: 0.7
                mass: 0.5
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: 80
                easing.type: Easing.OutCubic
            }
        }

        Image {
            id: backgroundImage
            anchors.fill: parent
            source: CiderRpcService.trackArtUrl || ""
            fillMode: Image.PreserveAspectCrop
            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blurMax: 48
                blur: 1
            }
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(Colors.scrim.r, Colors.scrim.g, Colors.scrim.b, 0.6)
            visible: backgroundImage.status === Image.Ready
        }

        ColumnLayout {
            id: mainLayout
            anchors.fill: parent
            anchors.margins: 14
            spacing: 6

            // Top row: art + title/artist
            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                Rectangle {
                    id: coverArtContainer
                    Layout.preferredWidth: 72
                    Layout.preferredHeight: 72
                    Layout.alignment: Qt.AlignVCenter
                    radius: 10
                    color: Colors.surface_container
                    layer.enabled: true

                    Image {
                        anchors.fill: parent
                        source: CiderRpcService.trackArtUrl || ""
                        fillMode: Image.PreserveAspectCrop
                    }

                    Text {
                        anchors.centerIn: parent
                        text: Icons.musicNote2
                        font.family: Fonts.iconFont
                        font.pixelSize: 28
                        color: Colors.on_surface_variant
                        visible: CiderRpcService.trackArtUrl === ""
                    }

                    Rectangle {
                        id: coverMask
                        width: coverArtContainer.width
                        height: coverArtContainer.height
                        radius: coverArtContainer.radius
                        visible: false
                    }

                    layer.effect: MultiEffect {
                        maskEnabled: true
                        maskSource: ShaderEffectSource {
                            sourceItem: coverMask
                            hideSource: true
                            live: true
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 3

                    Text {
                        Layout.fillWidth: true
                        text: CiderRpcService.trackTitle || "Unknown Title"
                        color: Colors.on_surface
                        font.pixelSize: 15
                        font.family: Fonts.font
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    Text {
                        Layout.fillWidth: true
                        text: CiderRpcService.trackArtist || "Unknown Artist"
                        color: Colors.on_surface_variant
                        font.pixelSize: 12
                        font.family: Fonts.font
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }
                }
            }

            // Seek bar + timestamps
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Timer {
                    id: seekDebounce
                    interval: 300
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
                        height: 3
                        radius: 3
                        color: Qt.rgba(Colors.on_surface_variant.r, Colors.on_surface_variant.g, Colors.on_surface_variant.b, 0.3)
                        Rectangle {
                            width: seekSlider.visualPosition * parent.width
                            height: parent.height
                            color: Colors.on_surface
                            radius: 3
                        }
                    }

                    handle: Rectangle {
                        x: seekSlider.leftPadding + seekSlider.visualPosition * (seekSlider.availableWidth - width)
                        y: seekSlider.topPadding + seekSlider.availableHeight / 2 - height / 2
                        implicitWidth: 10
                        implicitHeight: 10
                        radius: 5
                        color: Colors.on_surface
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: (seekSlider.pressed || seekDebounce.running) ? root.formatTime(seekSlider.value) : root.formatTime(CiderRpcService.position)
                        color: Colors.on_surface_variant
                        font.pixelSize: 10
                        font.family: Fonts.font
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    Text {
                        text: root.formatTime(CiderRpcService.duration)
                        color: Colors.on_surface_variant
                        font.pixelSize: 10
                        font.family: Fonts.font
                    }
                }
            }

            // Controls
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 20

                Rectangle {
                    width: 28
                    height: 28
                    color: "transparent"
                    Layout.alignment: Qt.AlignVCenter
                    Text {
                        anchors.centerIn: parent
                        text: Icons.skipPrevious
                        color: Colors.on_surface
                        font.pixelSize: 28
                        font.family: Fonts.iconFont
                    }
                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }
                    TapHandler {
                        onTapped: MediaControlService.previous()
                    }
                }

                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    Layout.alignment: Qt.AlignVCenter
                    color: Qt.rgba(Colors.on_surface.r, Colors.on_surface.g, Colors.on_surface.b, 0.15)
                    Text {
                        anchors.centerIn: parent
                        text: CiderRpcService.isPlaying ? Icons.pause : Icons.play
                        color: Colors.on_surface
                        font.pixelSize: 32
                        font.family: Fonts.iconFont
                    }
                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }
                    TapHandler {
                        onTapped: MediaControlService.playpause()
                    }
                }

                Rectangle {
                    width: 28
                    height: 28
                    color: "transparent"
                    Layout.alignment: Qt.AlignVCenter
                    Text {
                        anchors.centerIn: parent
                        text: Icons.skipNext
                        color: Colors.on_surface
                        font.pixelSize: 28
                        font.family: Fonts.iconFont
                    }
                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }
                    TapHandler {
                        onTapped: MediaControlService.next()
                    }
                }
            }
        }

        Rectangle {
            id: contentMask
            width: musicContent.width
            height: musicContent.height
            radius: musicContent.radius
            visible: false
        }

        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: ShaderEffectSource {
                sourceItem: contentMask
                hideSource: true
                live: true
            }
        }
    }
}
