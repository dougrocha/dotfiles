import QtQuick
import Quickshell
import Quickshell.Io
import qs.Constants
import qs.Services

PopupWindow {
    id: popup

    required property string panelName
    property Item trigger: null
    property int cardWidth: Theme.panel.width
    readonly property bool shown: Visibilities.isOpen(panelName)
    readonly property int contentMaxHeight: implicitHeight - Theme.panel.padding * 2
    default property alias content: column.data

    signal opened

    function close(): void {
        Visibilities.close(panelName);
    }

    function triggerOriginX() {
        if (!trigger || !anchor.window)
            return cardWidth;
        const triggerCenter = trigger.mapToItem(null, trigger.width / 2, 0).x;
        const inset = Theme.radius.xl;
        return Math.max(inset, Math.min(cardWidth - inset, triggerCenter - anchor.rect.x));
    }

    onShownChanged: {
        if (!shown)
            return;
        cardScale.origin.x = triggerOriginX();
        opened();
    }

    color: "transparent"
    visible: presence.mapped
    implicitWidth: cardWidth
    implicitHeight: {
        const win = anchor.window;
        return (win && win.screen) ? Math.max(400, win.screen.height - win.height - 12) : 800;
    }

    anchor.rect.x: anchor.window ? anchor.window.width - implicitWidth - Theme.space.md : 0
    anchor.rect.y: anchor.window ? anchor.window.height + Theme.space.xs : 0

    mask: Region {
        item: popup.shown ? card : null
    }

    IpcHandler {
        target: popup.panelName

        function open(): void {
            Visibilities.open(popup.panelName);
        }

        function hide(): void {
            Visibilities.close(popup.panelName);
        }

        function toggle(): void {
            Visibilities.toggle(popup.panelName);
        }
    }

    Presence {
        id: presence

        active: popup.shown
    }

    PopupGrab {
        active: popup.shown
        windows: popup.anchor.window ? [popup, popup.anchor.window] : [popup]
        onDismissed: popup.close()
    }

    Rectangle {
        id: card

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: column.implicitHeight + Theme.panel.padding * 2
        radius: Theme.radius.xl
        color: Theme.colors.surface
        clip: true
        enabled: popup.shown
        opacity: presence.progress
        transform: Scale {
            id: cardScale

            xScale: presence.scale
            yScale: presence.scale
        }

        SizeMotion on height {
            enabled: presence.progress === 1
        }

        focus: popup.shown
        Keys.onEscapePressed: popup.close()

        Column {
            id: column

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Theme.panel.padding
            spacing: Theme.space.xl
        }
    }
}
