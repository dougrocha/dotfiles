pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell.Widgets
import qs.Constants
import qs.Services

Rectangle {
    id: card

    readonly property int previewCount: ScreenshotToastService.paths.length
    readonly property bool shown: previewCount > 0

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

    property var dragPayload: null

    Drag.dragType: Drag.Automatic
    Drag.supportedActions: Qt.CopyAction
    Drag.proposedAction: Qt.CopyAction
    Drag.mimeData: dragPayload ? {
        "text/uri-list": dragPayload.uris
    } : ({})
    Drag.imageSource: dragPayload ? dragPayload.preview : ""
    Drag.imageSourceSize: Qt.size(card.cardWidth, card.cardHeight)
    Drag.hotSpot: Qt.point(width / 2, height / 2)
    Drag.onDragFinished: dropAction => {
        if (dropAction !== Qt.IgnoreAction)
            ScreenshotToastService.dismiss();
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

    width: card.cardWidth + card.framePadding * 2
    height: card.cardHeight + card.framePadding * 2
    radius: Theme.radius.surface
    color: Theme.colors.surface
    border.width: 1
    border.color: Theme.stroke.strong

    opacity: card.shown ? 1 : 0
    scale: card.shown ? 1 : Theme.motion.scaleFrom

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
        shadowColor: Theme.withAlpha(Theme.shadow, 0.45)
        shadowBlur: 0.6
        shadowVerticalOffset: 2
    }

    ClippingRectangle {
        anchors.fill: parent
        anchors.margins: card.framePadding
        radius: Math.max(0, parent.radius - card.framePadding)
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
            spacing: card.previewCount > 1 ? card.groupedSpacing : 0

            Repeater {
                model: ScreenshotToastService.paths

                delegate: Image {
                    required property string modelData
                    width: card.previewCount > 1 ? card.groupedPreviewWidth : parent.width
                    height: parent.height
                    source: ScreenshotToastService.localFileUrl(modelData)
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    cache: false
                }
            }
        }

        HoverHandler {
            onHoveredChanged: ScreenshotToastService.hoverPaused = hovered
        }

        TapHandler {
            onTapped: {
                if (!card.shown)
                    return;
                ScreenshotEditorService.open(ScreenshotToastService.path);
                ScreenshotToastService.dismiss();
            }
        }

        DragHandler {
            target: null
            onActiveChanged: {
                if (!active || card.Drag.active || !card.shown)
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
