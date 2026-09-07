import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Constants
import qs.Services

PanelWindow {
    color: "transparent"
    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs.tooltip"
    mask: Region {}

    visible: TooltipService.tooltipShown

    Rectangle {
        id: tip
        readonly property int padH: 10
        readonly property int padV: 4

        x: Math.max(4, Math.min(parent.width - width - 4, TooltipService.tooltipX - width / 2))
        y: Theme.topBarHeight + 6

        width: label.implicitWidth + padH * 2
        height: label.implicitHeight + padV * 2
        radius: Theme.radius.sm
        color: Theme.colors.raised
        border.color: Theme.stroke.strong
        border.width: 1
        opacity: TooltipService.tooltipShown ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: TooltipService.tooltipShown ? 120 : 80
                easing.type: TooltipService.tooltipShown ? Easing.OutCubic : Easing.InCubic
            }
        }

        Text {
            id: label
            anchors.centerIn: parent
            text: TooltipService.tooltipText
            color: Theme.text.primary
            renderType: Text.NativeRendering
            font.pixelSize: Theme.type.body.size
            font.family: Theme.font.ui
        }
    }
}
