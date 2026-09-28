import QtQuick
import Quickshell
import qs.Constants
import qs.Services

PopupWindow {
    id: popup

    required property string panelName
    readonly property bool shown: Visibilities.isOpen(panelName)
    property int cardWidth: 300
    property int cardPadding: Theme.space.lg
    readonly property int rowBleed: cardPadding - Theme.space.sm
    default property alias content: card.content

    signal opened

    function close() {
        Visibilities.close(panelName);
    }

    onShownChanged: if (shown)
        opened()

    color: "transparent"
    implicitWidth: cardWidth
    implicitHeight: {
        const win = anchor.window;
        return (win && win.screen) ? Math.max(400, win.screen.height - win.height - 12) : 800;
    }

    anchor.rect.x: anchor.window ? anchor.window.width - implicitWidth - Theme.space.md : 0
    anchor.rect.y: anchor.window ? anchor.window.height + Theme.space.xs : 0

    mask: Region {
        item: card
    }

    visible: shown

    PopupGrab {
        popup: popup
        onDismissed: popup.close()
    }

    PopupCard {
        id: card
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        padding: popup.cardPadding
        shown: popup.shown
        onDismissed: popup.close()
    }
}
