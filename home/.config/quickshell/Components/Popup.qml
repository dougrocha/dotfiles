import QtQuick
import Quickshell

PopupWindow {
    id: popup

    required property bool shown
    property int cardWidth: 300
    property int cardPadding: 10
    default property alias content: card.content

    signal dismissed

    color: "transparent"
    implicitWidth: cardWidth
    implicitHeight: {
        const win = anchor.window;
        return (win && win.screen) ? Math.max(400, win.screen.height - win.height - 12) : 800;
    }

    mask: Region {
        item: card
    }

    visible: shown

    PopupGrab {
        popup: popup
        onDismissed: popup.dismissed()
    }

    PopupCard {
        id: card
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        padding: popup.cardPadding
        shown: popup.shown
        onDismissed: popup.dismissed()
    }
}
