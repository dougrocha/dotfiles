import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Constants
import qs.Components
import qs.Services

RowLayout {
    id: screenshareComponent

    spacing: 0
    visible: StreamingService.isScreenshare || StreamingService.isRecordingScreen
    Layout.preferredWidth: visible ? implicitWidth : 0

    PopupWindow {
        id: screenSharePopup

        implicitHeight: 160
        implicitWidth: 320
        color: "transparent"
        visible: false

        anchor {
            item: screenShareText
            edges: Edges.Bottom | Edges.HCenter
            gravity: Edges.Bottom | Edges.HCenter
            margins.top: Theme.topBarHeight
        }

        PopupGrab {
            popup: screenSharePopup
            anchorWindow: screenShareText.QsWindow.window
            onDismissed: screenSharePopup.visible = false
        }

        Rectangle {
            anchors.fill: parent
            color: Colors.surface_container_low
            radius: 12
            border.width: 1
            border.color: Colors.outline_variant

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                Text {
                    text: "Screen Being Shared"
                    color: Colors.on_surface
                    font.pixelSize: 14
                    font.family: Fonts.font
                    font.bold: true
                }

                Text {
                    Layout.fillWidth: true
                    text: "Sharing screen via xdph-streaming"
                    color: Colors.on_surface_variant
                    font.pixelSize: 11
                    font.family: Fonts.font
                    wrapMode: Text.WordWrap
                }

                Text {
                    visible: StreamingService.screenAccessApps.length > 0
                    Layout.fillWidth: true
                    text: "Apps accessing screen:\n" + StreamingService.screenAccessApps.join(", ")
                    color: Colors.on_surface_variant
                    font.pixelSize: 10
                    font.family: Fonts.font
                    wrapMode: Text.WordWrap
                    opacity: 0.8
                }

                Item {
                    Layout.fillHeight: true
                }

                Rectangle {
                    visible: !StreamingService.isScreenshare
                    Layout.fillWidth: true
                    height: 32
                    color: Colors.primary
                    radius: 6

                    Text {
                        anchors.centerIn: parent
                        text: "Stop Recording"
                        color: Colors.on_primary
                        font.pixelSize: 12
                        font.family: Fonts.font
                        font.bold: true
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        onTapped: {
                            StreamingService.stopRecording();
                            screenSharePopup.visible = false;
                        }
                    }
                }
            }
        }
    }

    Text {
        id: screenShareText

        text: Icons.screenShare
        color: Colors.error
        font.pixelSize: 14
        font.family: Fonts.iconFont
        font.bold: true
        Layout.rightMargin: 8
        visible: StreamingService.isScreenshare

        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: {
                Visibilities.closePopups();
                screenSharePopup.visible = !screenSharePopup.visible;
            }
        }
    }

    Text {
        id: recordingText

        text: Icons.screenRecord
        color: Colors.error
        font.pixelSize: 14
        font.family: Fonts.iconFont
        font.bold: true
        Layout.rightMargin: 8
        visible: !StreamingService.isScreenshare

        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: {
                Visibilities.closePopups();
                if (StreamingService.isRecordingScreen) {
                    StreamingService.stopRecording();
                } else {
                    recordingOptionsPopup.visible = !recordingOptionsPopup.visible;
                }
            }
        }
    }

    PopupWindow {
        id: recordingOptionsPopup

        implicitHeight: 200
        implicitWidth: 300
        color: "transparent"
        visible: false

        anchor {
            item: recordingText
            edges: Edges.Bottom | Edges.HCenter
            gravity: Edges.Bottom | Edges.HCenter
            margins.top: Theme.topBarHeight
        }

        PopupGrab {
            popup: recordingOptionsPopup
            anchorWindow: recordingText.QsWindow.window
            onDismissed: recordingOptionsPopup.visible = false
        }

        Rectangle {
            anchors.fill: parent
            color: Colors.surface_container_low
            radius: 12
            border.width: 1
            border.color: Colors.outline_variant

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                Text {
                    text: "Start Recording"
                    color: Colors.on_surface
                    font.pixelSize: 14
                    font.family: Fonts.font
                    font.bold: true
                }

                Item {
                    Layout.fillHeight: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 36
                    color: Colors.primary
                    radius: 6

                    Text {
                        anchors.centerIn: parent
                        text: "Full Screen"
                        color: Colors.on_primary
                        font.pixelSize: 12
                        font.family: Fonts.font
                        font.bold: true
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        onTapped: {
                            let startProc = Qt.createQmlObject('import Quickshell; Process { command: ["start-recording", "screen"] }', recordingOptionsPopup);
                            startProc.running = true;
                            recordingOptionsPopup.visible = false;
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 36
                    color: Colors.secondary
                    radius: 6

                    Text {
                        anchors.centerIn: parent
                        text: "DP-1"
                        color: Colors.on_secondary
                        font.pixelSize: 12
                        font.family: Fonts.font
                        font.bold: true
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        onTapped: {
                            let startProc = Qt.createQmlObject('import Quickshell; Process { command: ["start-recording", "DP-1"] }', recordingOptionsPopup);
                            startProc.running = true;
                            recordingOptionsPopup.visible = false;
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 36
                    color: Colors.secondary
                    radius: 6

                    Text {
                        anchors.centerIn: parent
                        text: "DP-2"
                        color: Colors.on_secondary
                        font.pixelSize: 12
                        font.family: Fonts.font
                        font.bold: true
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        onTapped: {
                            let startProc = Qt.createQmlObject('import Quickshell; Process { command: ["start-recording", "DP-2"] }', recordingOptionsPopup);
                            startProc.running = true;
                            recordingOptionsPopup.visible = false;
                        }
                    }
                }
            }
        }
    }
}
