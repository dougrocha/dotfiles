import QtQuick
import qs.Components

PanelScroll {
    id: card

    property var menuHandle: null

    signal closeRequested

    bleed: 0

    TrayMenuList {
        width: parent.width
        menuHandle: card.menuHandle
        onCloseRequested: card.closeRequested()
    }
}
