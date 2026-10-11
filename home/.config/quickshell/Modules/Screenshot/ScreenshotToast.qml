pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
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

        implicitWidth: toastWindow.cardWidth + toastWindow.framePadding * 2 + Theme.space.lg * 2
        implicitHeight: toastWindow.cardHeight + toastWindow.framePadding * 2 + Theme.space.lg * 2

        visible: toastWindow.shown || card.Drag.active

        mask: Region {
            item: toastWindow.visible ? card : null
        }

        Rectangle {
            id: card

            property var dragPayload: null

            Drag.dragType: Drag.Automatic
            Drag.supportedActions: Qt.CopyAction
            Drag.proposedAction: Qt.CopyAction
            Drag.mimeData: dragPayload ? {
                "text/uri-list": dragPayload.uris
            } : ({})
            Drag.imageSource: dragPayload ? dragPayload.preview : ""
            Drag.imageSourceSize: Qt.size(toastWindow.cardWidth, toastWindow.cardHeight)
            Drag.hotSpot: Qt.point(width / 2, height / 2)
            Drag.onDragFinished: {
                card.Drag.active = false;
            }
            Drag.onActiveChanged: {
                if (!card.Drag.active && card.dragPayload !== null) {
                    card.dragPayload = null;
                    ScreenshotToastService.dragPaused = false;
                }
            }
            Component.onDestruction: {
                if (card.dragPayload !== null) {
                    card.Drag.cancel();
                    ScreenshotToastService.dragPaused = false;
                }
            }

            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: Theme.space.lg

            width: toastWindow.cardWidth + toastWindow.framePadding * 2
            height: toastWindow.cardHeight + toastWindow.framePadding * 2
            radius: Theme.radius.xl
            color: Theme.colors.surface
            border.width: 1
            border.color: Theme.stroke.strong

            opacity: toastWindow.shown ? 1 : 0
            scale: toastWindow.shown ? 1 : Theme.motion.scaleFrom

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.motion.normal
                    easing.type: Theme.motion.easeStandard
                }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: Theme.motion.normal
                    easing.type: Theme.motion.easeStandard
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
                    source: ScreenshotToastService.path !== "" ? ScreenshotToastService.localFileUrl(ScreenshotToastService.path) : ""
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
                            source: ScreenshotToastService.localFileUrl(modelData)
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
                    acceptedButtons: Qt.LeftButton
                    gesturePolicy: TapHandler.DragThreshold
                    onTapped: {
                        if (ScreenshotToastService.paths.length === 0)
                            return;
                        Quickshell.execDetached(["imv"].concat(ScreenshotToastService.paths));
                        ScreenshotToastService.dismiss();
                    }
                }

                DragHandler {
                    target: null
                    acceptedButtons: Qt.LeftButton
                    onActiveChanged: {
                        if (!active || card.Drag.active || ScreenshotToastService.paths.length === 0)
                            return;
                        const urls = ScreenshotToastService.paths.map(path => ScreenshotToastService.localFileUrl(path));
                        card.dragPayload = {
                            uris: urls.join("\r\n") + "\r\n",
                            preview: urls[0]
                        };
                        ScreenshotToastService.dragPaused = true;
                        card.Drag.active = true;
                    }
                }
            }
        }
    }
}
