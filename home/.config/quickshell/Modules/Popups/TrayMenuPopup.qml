import QtQuick
import Quickshell
import qs.Components
import qs.Constants

Popover {
    id: root

    property Item anchorItem
    property var menuOpener: null

    menu: true
    hostWindow: anchorItem ? anchorItem.QsWindow.window : null

    anchor.item: root.anchorItem
    anchor.rect.x: {
        if (!anchorItem || !hostWindow)
            return 0;

        const anchorPosition = anchorItem.mapToItem(null, 0, 0).x;
        const desiredPosition = anchorPosition + anchorItem.width / 2 - implicitWidth / 2;
        const clampedPosition = Math.max(4, Math.min(hostWindow.width - implicitWidth - 4, desiredPosition));
        return Math.round(clampedPosition - anchorPosition);
    }
    anchor.rect.y: anchorItem ? anchorItem.height + 12 : 0

    TrayMenuCard {
        menuHandle: root.menuOpener?.menu ?? null
        onCloseRequested: root.dismissed()
    }
}
