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

    TooltipBubble {
        id: tip

        x: Math.max(Theme.space.xs, Math.min(parent.width - width - Theme.space.xs, TooltipService.tooltipX - width / 2))
        y: Theme.topBarHeight + Theme.space.sm
        width: implicitWidth
        height: implicitHeight
        text: TooltipService.tooltipText
        opacity: presence.progress
        scale: presence.scale
        transformOrigin: Item.Top
    }
}
