import "../Components"
import "../Services"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

Item {
    id: root

    property color iconColor
    property color colYellow
    property color colMuted
    property int fontSize
    property string fontFamily
    readonly property bool showCider: CiderRpcService.isOnline

    MouseArea {
        anchors.fill: parent
        cursorShape: showCider ? Qt.PointingHandCursor : Qt.ArrowCursor
        enabled: showCider
        onClicked: {
            if (!mediaPanelPopupLoader.loading)
                mediaPanelPopupLoader.loading = true;

            if (mediaPanelPopupLoader.item)
                mediaPanelPopupLoader.item.visible = !mediaPanelPopupLoader.item.visible;
        }
    }

    LazyLoader {
        id: mediaPanelPopupLoader

        loading: false

        PanelWindow {
            id: mediaPanel

            function formatTime(seconds) {
                if (!seconds || seconds < 0)
                    return "0:00";

                var mins = Math.floor(seconds / 60);
                var secs = Math.floor(seconds % 60);
                return mins + ":" + (secs < 10 ? "0" : "") + secs;
            }

            visible: false
            implicitWidth: 480
            implicitHeight: 260
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

                active: mediaPanel.visible
                windows: [mediaPanel]
                onActiveChanged: {
                    if (!active && mediaPanel.visible)
                        mediaPanel.visible = false;
                }
            }

            Rectangle {
                id: contentRect

                anchors.fill: parent
                color: "#1a1512"
                radius: 16
                border.color: "#3d3027"
                border.width: 1
            }

            // Favorite star and library icon - top right
            RowLayout {
                spacing: 12
                visible: showCider

                anchors {
                    top: parent.top
                    topMargin: 16
                    right: parent.right
                    rightMargin: 16
                }

                // Favorite star
                Text {
                    text: CiderRpcService.inFavorites ? "★" : "☆"
                    color: CiderRpcService.inFavorites ? "#d4a574" : "#8b7a6a"
                    font.pixelSize: 24
                    font.family: fontFamily
                }

                // Library status (checkmark or plus) - clickable
                MouseArea {
                    implicitWidth: 32
                    implicitHeight: 32
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!CiderRpcService.inLibrary)
                            CiderRpcService.addToLibrary();
                    }

                    Text {
                        anchors.centerIn: parent
                        text: CiderRpcService.inLibrary ? "✓" : "+"
                        color: CiderRpcService.inLibrary ? "#d4a574" : "#8b7a6a"
                        font.pixelSize: 24
                        font.family: parent.parent.fontFamily
                    }
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 14

                // Album Art - Large on left
                Rectangle {
                    Layout.preferredWidth: 180
                    Layout.preferredHeight: 180
                    radius: 12
                    color: "#3d3027"
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: CiderRpcService.trackArtUrl || ""
                        fillMode: Image.PreserveAspectCrop
                        visible: CiderRpcService.trackArtUrl && CiderRpcService.trackArtUrl.length > 0
                    }

                    // Fallback icon when no artwork
                    Text {
                        anchors.centerIn: parent
                        text: "󰝚"
                        color: "#8b7a6a"
                        font.pixelSize: 64
                        font.family: root.fontFamily
                        visible: !CiderRpcService.trackArtUrl || CiderRpcService.trackArtUrl.length === 0
                    }
                }

                // Right side - Track info and controls
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 10

                    Item {
                        Layout.fillHeight: true
                    }

                    // Track Title - Large
                    Text {
                        Layout.fillWidth: true
                        text: CiderRpcService.trackTitle || "No Title"
                        color: "#ffffff"
                        font.pixelSize: 28
                        font.family: root.fontFamily
                        font.bold: true
                        elide: Text.ElideRight
                        wrapMode: Text.NoWrap
                    }

                    // Artist info
                    Text {
                        Layout.fillWidth: true
                        text: CiderRpcService.trackArtist || "Unknown Artist"
                        color: "#98989f"
                        font.pixelSize: 15
                        font.family: root.fontFamily
                        elide: Text.ElideRight
                    }

                    // Media Controls
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 20
                        spacing: 28

                        Item {
                            Layout.fillWidth: true
                        }

                        MediaControlButton {
                            icon: "󰒮"
                            size: 24
                            iconColor: "#ffffff"
                            onClicked: function () {
                                MediaControlService.previous();
                            }
                        }

                        MediaControlButton {
                            icon: CiderRpcService.isPlaying ? "󰏤" : "󰐊"
                            size: 44
                            isPrimary: true
                            iconColor: "#ffffff"
                            onClicked: function () {
                                MediaControlService.playpause();
                            }
                        }

                        MediaControlButton {
                            icon: "󰒭"
                            size: 24
                            iconColor: "#ffffff"
                            onClicked: function () {
                                MediaControlService.next();
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }
                    }

                    // Debounce timer for seek slider - prevents websocket updates right after release
                    Timer {
                        id: seekDebounce

                        interval: 300
                        running: false
                    }

                    // Seek Slider
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 16
                        spacing: 6

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

                            background: Rectangle {
                                x: seekSlider.leftPadding
                                y: seekSlider.topPadding + seekSlider.availableHeight / 2 - height / 2
                                width: seekSlider.availableWidth
                                height: 4
                                radius: 2
                                color: "#3d3027"

                                Rectangle {
                                    width: seekSlider.visualPosition * parent.width
                                    height: parent.height
                                    color: "#d4a574"
                                    radius: 2
                                }
                            }

                            handle: Rectangle {
                                x: seekSlider.leftPadding + seekSlider.visualPosition * (seekSlider.availableWidth - width)
                                y: seekSlider.topPadding + seekSlider.availableHeight / 2 - height / 2
                                implicitWidth: 12
                                implicitHeight: 12
                                radius: 6
                                color: seekSlider.pressed ? "#e8c89a" : "#d4a574"
                            }
                        }

                        // Time labels
                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: (seekSlider.pressed || seekDebounce.running) ? formatTime(seekSlider.value) : formatTime(CiderRpcService.position)
                                color: "#98989f"
                                font.pixelSize: 12
                                font.family: root.fontFamily
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                text: formatTime(CiderRpcService.duration)
                                color: "#98989f"
                                font.pixelSize: 12
                                font.family: root.fontFamily
                            }
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }
            }

            mask: Region {
                item: contentRect
            }
        }
    }
}
