pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.Constants

Item {
    id: manager

    property bool overlayVisible: false
    property int timerDelay: 0
    property string selectedMode: "region"
    property string pendingMode: ""
    property bool showCursor: false
    property bool micEnabled: false
    property bool optionsOpen: false

    IpcHandler {
        target: "screenshot-overlay"

        function show(): void {
            manager.overlayVisible = true;
        }
        function hide(): void {
            manager.overlayVisible = false;
        }
        function toggle(): void {
            manager.overlayVisible = !manager.overlayVisible;
        }
    }

    Process { id: screenshotProcess }
    Process { id: toggleRecordingProcess }

    onOverlayVisibleChanged: {
        if (!overlayVisible && pendingMode !== "" && pendingMode !== "video") {
            executeAction();
        }
    }

    function capture() {
        pendingMode = selectedMode;
        optionsOpen = false;
        if (pendingMode === "video") {
            overlayVisible = false;
            executeAction();
            return;
        }
        overlayVisible = false;
    }

    function executeAction() {
        if (pendingMode === "video") {
            toggleRecordingProcess.command = manager.micEnabled
                ? ["toggle-recording"]
                : ["toggle-recording", "--no-audio"];
            toggleRecordingProcess.running = true;
        } else {
            let args = ["screenshot"];
            if (timerDelay > 0) args = args.concat(["--delay", timerDelay.toString()]);
            if (showCursor) args.push("--cursor");
            args.push(pendingMode);
            screenshotProcess.command = args;
            screenshotProcess.running = true;
        }
        pendingMode = "";
    }

    function dismiss() {
        pendingMode = "";
        overlayVisible = false;
        optionsOpen = false;
    }

    Variants {
        model: manager.overlayVisible ? Quickshell.screens : []

        delegate: PanelWindow {
            id: overlayWindow
            required property var modelData
            screen: modelData

            readonly property bool isFocusedScreen:
                Hyprland.focusedMonitor != null &&
                modelData.name === Hyprland.focusedMonitor.name

            visible: manager.overlayVisible
            color: "transparent"

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "qs.screenshot_overlay"
            WlrLayershell.keyboardFocus: (overlayWindow.isFocusedScreen && overlayWindow.visible)
                ? WlrKeyboardFocus.Exclusive
                : WlrKeyboardFocus.None
            WlrLayershell.exclusionMode: ExclusionMode.Ignore

            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true

            onVisibleChanged: {
                if (visible && overlayWindow.isFocusedScreen) {
                    keyHandler.forceActiveFocus();
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (manager.optionsOpen) {
                        manager.optionsOpen = false;
                    } else {
                        manager.dismiss();
                    }
                }
            }

            Item {
                id: keyHandler
                focus: overlayWindow.isFocusedScreen && overlayWindow.visible
                Keys.onEscapePressed: manager.dismiss()
                Keys.onReturnPressed: manager.capture()
                Keys.onEnterPressed: manager.capture()
            }

            // Options panel
            Rectangle {
                id: optionsPanel
                visible: overlayWindow.isFocusedScreen && manager.overlayVisible
                enabled: manager.optionsOpen

                anchors.bottom: toolbar.top
                anchors.bottomMargin: 8
                anchors.horizontalCenter: toolbar.horizontalCenter

                implicitWidth: 264
                implicitHeight: optionsColumn.implicitHeight + 24
                radius: 16
                color: Colors.surface_container
                border.width: 1
                border.color: Colors.outline_variant

                opacity: manager.optionsOpen ? 1.0 : 0.0
                scale: manager.optionsOpen ? 1.0 : 0.95
                transformOrigin: Item.Bottom

                Behavior on opacity { NumberAnimation { duration: Theme.animations.fast } }
                Behavior on scale { NumberAnimation { duration: Theme.animations.fast } }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {}
                }

                ColumnLayout {
                    id: optionsColumn
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: 12
                    }
                    spacing: 2

                    Text {
                        text: "Timer"
                        color: Colors.on_surface_variant
                        font.pixelSize: 11
                        font.family: Fonts.font
                        Layout.topMargin: 4
                        Layout.leftMargin: 4
                        Layout.bottomMargin: 2
                    }

                    RowLayout {
                        spacing: 4
                        Layout.fillWidth: true

                        Repeater {
                            model: [
                                { delay: 0,  label: "None" },
                                { delay: 3,  label: "3s"   },
                                { delay: 5,  label: "5s"   },
                                { delay: 10, label: "10s"  }
                            ]

                            delegate: Rectangle {
                                required property var modelData
                                Layout.fillWidth: true
                                implicitHeight: 32
                                radius: 8
                                color: manager.timerDelay === modelData.delay
                                    ? Colors.primary_container
                                    : (timerOptArea.containsMouse
                                        ? Colors.surface_container_high
                                        : Colors.surface_container_low)

                                Behavior on color { ColorAnimation { duration: Theme.animations.fast } }

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    color: manager.timerDelay === modelData.delay
                                        ? Colors.on_primary_container
                                        : Colors.on_surface_variant
                                    font.pixelSize: 12
                                    font.family: Fonts.font
                                }

                                MouseArea {
                                    id: timerOptArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: manager.timerDelay = modelData.delay
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: Colors.outline_variant
                        Layout.topMargin: 6
                        Layout.bottomMargin: 2
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 40
                        radius: 8
                        color: cursorOptArea.containsMouse ? Colors.surface_container_high : "transparent"
                        Behavior on color { ColorAnimation { duration: Theme.animations.fast } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8

                            Text {
                                text: PhosphorIcons.mouse
                                color: Colors.on_surface_variant
                                font.pixelSize: 18
                                font.family: Fonts.phosphorFont
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "Show Cursor"
                                color: Colors.on_surface
                                font.pixelSize: 13
                                font.family: Fonts.font
                                leftPadding: 8
                            }
                            Text {
                                text: PhosphorIcons.check
                                color: Colors.primary
                                font.pixelSize: 18
                                font.family: Fonts.phosphorFill
                                visible: manager.showCursor
                            }
                        }

                        MouseArea {
                            id: cursorOptArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: manager.showCursor = !manager.showCursor
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 40
                        radius: 8
                        color: micOptArea.containsMouse ? Colors.surface_container_high : "transparent"
                        Behavior on color { ColorAnimation { duration: Theme.animations.fast } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8

                            Text {
                                text: manager.micEnabled ? PhosphorIcons.microphone : PhosphorIcons.microphoneSlash
                                color: Colors.on_surface_variant
                                font.pixelSize: 18
                                font.family: Fonts.phosphorFont
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "Microphone"
                                color: Colors.on_surface
                                font.pixelSize: 13
                                font.family: Fonts.font
                                leftPadding: 8
                            }
                            Text {
                                text: PhosphorIcons.check
                                color: Colors.primary
                                font.pixelSize: 18
                                font.family: Fonts.phosphorFill
                                visible: manager.micEnabled
                            }
                        }

                        MouseArea {
                            id: micOptArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: manager.micEnabled = !manager.micEnabled
                        }
                    }

                    Item { implicitHeight: 4 }
                }
            }

            // Toolbar
            Rectangle {
                id: toolbar
                visible: overlayWindow.isFocusedScreen && manager.overlayVisible

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 52

                implicitWidth: toolbarRow.implicitWidth + 20
                implicitHeight: 64
                radius: 16
                color: Colors.surface_container
                border.width: 1
                border.color: Colors.outline_variant

                layer.enabled: true
                layer.effect: null

                MouseArea {
                    anchors.fill: parent
                    onClicked: {}
                }

                RowLayout {
                    id: toolbarRow
                    anchors.centerIn: parent
                    spacing: 2

                    // Close button
                    Item {
                        implicitWidth: 28
                        implicitHeight: 28
                        Layout.rightMargin: 2

                        Text {
                            anchors.centerIn: parent
                            text: PhosphorIcons.xCircle
                            color: Colors.outline
                            font.pixelSize: 22
                            font.family: Fonts.phosphorFill
                        }

                        MouseArea {
                            id: closeArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: manager.dismiss()
                        }
                    }

                    // Screenshot buttons
                    Repeater {
                        model: [
                            { mode: "region",     icon: PhosphorIcons.selection },
                            { mode: "windows",    icon: PhosphorIcons.appWindow },
                            { mode: "fullscreen", icon: PhosphorIcons.monitor   }
                        ]

                        delegate: Rectangle {
                            required property var modelData
                            implicitWidth: 44
                            implicitHeight: 44
                            radius: 10
                            color: manager.selectedMode === modelData.mode || modeArea.containsMouse
                                ? Colors.surface_container_high : "transparent"

                            Behavior on color { ColorAnimation { duration: Theme.animations.fast } }

                            Text {
                                anchors.centerIn: parent
                                text: modelData.icon
                                color: manager.selectedMode === modelData.mode
                                    ? Colors.on_surface : Colors.on_surface_variant
                                font.pixelSize: 22
                                font.family: Fonts.phosphorFont
                                Behavior on color { ColorAnimation { duration: Theme.animations.fast } }
                            }

                            Rectangle {
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 4
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 4; height: 4; radius: 2
                                color: Colors.primary
                                visible: manager.selectedMode === modelData.mode
                            }

                            MouseArea {
                                id: modeArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: manager.selectedMode = modelData.mode
                            }
                        }
                    }

                    Rectangle {
                        implicitWidth: 1
                        implicitHeight: 32
                        Layout.alignment: Qt.AlignVCenter
                        color: Colors.outline_variant
                        Layout.leftMargin: 4
                        Layout.rightMargin: 4
                    }

                    // Video button
                    Rectangle {
                        implicitWidth: 44
                        implicitHeight: 44
                        radius: 10
                        color: manager.selectedMode === "video" || videoArea.containsMouse
                            ? Colors.surface_container_high : "transparent"

                        Behavior on color { ColorAnimation { duration: Theme.animations.fast } }

                        Text {
                            anchors.centerIn: parent
                            text: PhosphorIcons.videoCamera
                            color: manager.selectedMode === "video"
                                ? Colors.on_surface : Colors.on_surface_variant
                            font.pixelSize: 22
                            font.family: Fonts.phosphorFont
                            Behavior on color { ColorAnimation { duration: Theme.animations.fast } }
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 4
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 4; height: 4; radius: 2
                            color: Colors.primary
                            visible: manager.selectedMode === "video"
                        }

                        MouseArea {
                            id: videoArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: manager.selectedMode = "video"
                        }
                    }

                    Rectangle {
                        implicitWidth: 1
                        implicitHeight: 32
                        Layout.alignment: Qt.AlignVCenter
                        color: Colors.outline_variant
                        Layout.leftMargin: 4
                        Layout.rightMargin: 4
                    }

                    // Options text button
                    Rectangle {
                        implicitWidth: optionsLabel.implicitWidth + 20
                        implicitHeight: 44
                        radius: 10
                        color: manager.optionsOpen
                            ? Colors.surface_container_high
                            : (optionsBtn.containsMouse
                                ? Colors.surface_container_high
                                : "transparent")

                        Behavior on color { ColorAnimation { duration: Theme.animations.fast } }

                        Row {
                            id: optionsLabel
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                text: "Options"
                                color: Colors.on_surface
                                font.pixelSize: 13
                                font.family: Fonts.font
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: PhosphorIcons.caretDown
                                color: Colors.on_surface_variant
                                font.pixelSize: 14
                                font.family: Fonts.phosphorFont
                                anchors.verticalCenter: parent.verticalCenter

                                rotation: manager.optionsOpen ? 180 : 0
                                Behavior on rotation { NumberAnimation { duration: Theme.animations.fast } }
                            }
                        }

                        MouseArea {
                            id: optionsBtn
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: manager.optionsOpen = !manager.optionsOpen
                        }
                    }

                    // Capture button
                    Rectangle {
                        implicitWidth: captureLabel.implicitWidth + 28
                        implicitHeight: 44
                        radius: 22
                        color: captureBtn.containsMouse
                            ? Qt.lighter(Colors.primary, 1.1)
                            : Colors.primary
                        Layout.leftMargin: 4

                        Behavior on color { ColorAnimation { duration: Theme.animations.fast } }

                        Text {
                            id: captureLabel
                            anchors.centerIn: parent
                            text: "Capture"
                            color: Colors.on_primary
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            font.family: Fonts.font
                        }

                        MouseArea {
                            id: captureBtn
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: manager.capture()
                        }
                    }
                }
            }
        }
    }
}
