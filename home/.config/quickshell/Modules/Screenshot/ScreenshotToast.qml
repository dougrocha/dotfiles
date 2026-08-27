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

        readonly property bool shown: ScreenshotToastService.paths.length > 0
        readonly property int previewCount: ScreenshotToastService.paths.length

        readonly property real maxDimension: 220
        readonly property real groupedPreviewWidth: 180
        readonly property real groupedPreviewHeight: 112
        readonly property real groupedSpacing: 2
        readonly property real framePadding: 2
        readonly property real naturalW: thumbProbe.sourceSize.width > 0 ? thumbProbe.sourceSize.width : 16
        readonly property real naturalH: thumbProbe.sourceSize.height > 0 ? thumbProbe.sourceSize.height : 9
        readonly property real fitScale: Math.min(maxDimension / naturalW, maxDimension / naturalH, 1)
        readonly property real cardWidth: previewCount > 1 ? previewCount * groupedPreviewWidth + (previewCount - 1) * groupedSpacing : Math.round(naturalW * fitScale)
        readonly property real cardHeight: previewCount > 1 ? groupedPreviewHeight : Math.round(naturalH * fitScale)

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
                    id: thumbProbe
                    visible: false
                    source: ScreenshotToastService.path !== "" ? "file://" + ScreenshotToastService.path : ""
                    asynchronous: true
                    cache: false
                }

                Row {
                    anchors.fill: parent
                    spacing: toastWindow.previewCount > 1 ? toastWindow.groupedSpacing : 0

                    Repeater {
                        model: ScreenshotToastService.paths

                        delegate: Image {
                            required property string modelData
                            width: toastWindow.previewCount > 1 ? toastWindow.groupedPreviewWidth : parent.width
                            height: parent.height
                            source: "file://" + modelData
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            cache: false
                        }
                    }
                }

                HoverHandler {
                    id: cardHover
                    onHoveredChanged: ScreenshotToastService.hoverPaused = hovered
                }

                TapHandler {
                    onTapped: {
                        if (ScreenshotToastService.paths.length === 0)
                            return;
                        openProcess.command = ["imv"].concat(ScreenshotToastService.paths);
                        openProcess.running = true;
                        ScreenshotToastService.dismiss();
                    }
                }
            }
        }
    }
}
