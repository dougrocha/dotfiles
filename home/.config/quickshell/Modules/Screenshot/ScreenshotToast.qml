pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Constants
import qs.Services

Variants {
    id: root
    model: Theme.primaryScreens

    delegate: PanelWindow {
        id: toastWindow

        required property var modelData
        screen: modelData

        readonly property bool shown: ScreenshotToastService.path !== ""

        readonly property real maxDimension: 220
        readonly property real framePadding: 2
        readonly property real naturalW: thumb.sourceSize.width > 0 ? thumb.sourceSize.width : 16
        readonly property real naturalH: thumb.sourceSize.height > 0 ? thumb.sourceSize.height : 9
        readonly property real fitScale: Math.min(maxDimension / naturalW, maxDimension / naturalH, 1)
        readonly property real cardWidth: Math.round(naturalW * fitScale)
        readonly property real cardHeight: Math.round(naturalH * fitScale)

        color: "transparent"
        focusable: false

        WlrLayershell.namespace: "qs.screenshot_toast"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.exclusionMode: ExclusionMode.Ignore

        anchors {
            bottom: true
            right: true
        }

        implicitWidth: toastWindow.cardWidth + toastWindow.framePadding * 2 + Theme.notifications.margin * 2
        implicitHeight: toastWindow.cardHeight + toastWindow.framePadding * 2 + Theme.notifications.margin * 2

        visible: toastWindow.shown

        mask: Region {
            item: toastWindow.shown ? card : null
        }

        Process {
            id: openProcess
        }

        Rectangle {
            id: card

            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: Theme.notifications.margin

            width: toastWindow.cardWidth + toastWindow.framePadding * 2
            height: toastWindow.cardHeight + toastWindow.framePadding * 2
            radius: 16
            color: Colors.surface_container
            border.width: 1
            border.color: Colors.on_surface

            opacity: toastWindow.shown ? 1 : 0
            scale: toastWindow.shown ? 1 : 0.92

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.animations.normal
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: Theme.animations.normal
                    easing.type: Easing.OutCubic
                }
            }

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Qt.rgba(0, 0, 0, 0.45)
                shadowBlur: 0.6
                shadowVerticalOffset: 2
            }

            ClippingRectangle {
                anchors.fill: parent
                anchors.margins: toastWindow.framePadding
                radius: Math.max(0, parent.radius - toastWindow.framePadding)
                color: "transparent"

                Image {
                    id: thumb
                    anchors.fill: parent
                    source: ScreenshotToastService.path !== "" ? "file://" + ScreenshotToastService.path : ""
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    cache: false
                }

                HoverHandler {
                    id: cardHover
                    onHoveredChanged: ScreenshotToastService.hoverPaused = hovered
                }

                TapHandler {
                    onTapped: {
                        if (ScreenshotToastService.path === "")
                            return;
                        openProcess.command = ["imv", ScreenshotToastService.path];
                        openProcess.running = true;
                        ScreenshotToastService.dismiss();
                    }
                }
            }
        }
    }
}
