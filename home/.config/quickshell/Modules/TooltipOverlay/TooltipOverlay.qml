import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Components
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

    visible: presence.mapped

    Presence {
        id: presence

        active: TooltipService.tooltipShown
    }

    Rectangle {
        id: tip
        readonly property int padH: 10

        x: Math.max(Theme.space.xs, Math.min(parent.width - width - Theme.space.xs, TooltipService.tooltipX - width / 2))
        y: Theme.topBarHeight + Theme.space.sm

        width: label.implicitWidth + padH * 2
        height: label.implicitHeight + Theme.space.xs * 2
        radius: Theme.radius.sm
        color: Theme.colors.raised
        border.color: Theme.stroke.strong
        border.width: 1
        opacity: presence.progress
        scale: presence.scale
        transformOrigin: Item.Top

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
