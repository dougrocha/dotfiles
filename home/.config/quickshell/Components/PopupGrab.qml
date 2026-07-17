import QtQuick
import Quickshell
import Quickshell.Hyprland

Scope {
    id: root

    required property var popup
    property var anchorWindow: popup ? popup.anchor.window : null

    signal dismissed

    HyprlandFocusGrab {
        id: grab
        active: false
        windows: root.anchorWindow ? [root.popup, root.anchorWindow] : [root.popup]
        onCleared: root.dismissed()
    }

    Timer {
        id: grabDelay
        interval: 50
        repeat: false
        onTriggered: grab.active = true
    }

    Connections {
        target: root.popup

        function onVisibleChanged() {
            if (root.popup.visible) {
                grabDelay.restart();
            } else {
                grabDelay.stop();
                grab.active = false;
            }
        }
    }
}
