import QtQuick
import qs.Constants
import qs.Services
import "../Constants/MathUtil.js" as MathUtil

Popover {
    id: popup

    required property string panelName
    property Item trigger: null

    function close(): void {
        Visibilities.close(panelName);
    }

    function triggerOriginX() {
        if (!trigger || !anchor.window)
            return implicitWidth;
        const triggerCenter = trigger.mapToItem(null, trigger.width / 2, 0).x;
        const inset = Theme.panel.padding;
        return MathUtil.clamp(triggerCenter - anchor.rect.x, inset, implicitWidth - inset);
    }

    open: Visibilities.isOpen(panelName)
    hostWindow: anchor.window
    onOpenChanged: {
        if (open)
            originX = triggerOriginX();
    }
    onDismissed: close()

    anchor.rect.x: anchor.window ? anchor.window.width - implicitWidth - Theme.space.md : 0
    anchor.rect.y: anchor.window ? anchor.window.height + Theme.space.xs : 0
}
