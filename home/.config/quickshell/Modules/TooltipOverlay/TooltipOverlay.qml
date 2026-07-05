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
        radius: 6
        color: Colors.surface_container_high
        border.color: Qt.rgba(Colors.on_surface.r, Colors.on_surface.g, Colors.on_surface.b, 0.15)
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
            color: Colors.on_surface
            renderType: Text.NativeRendering
            font.pixelSize: Fonts.p - 1
            font.family: Fonts.font
        }
    }
}
