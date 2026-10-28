import QtQuick
import Quickshell
import Quickshell.Hyprland

Scope {
    id: root

    required property bool active
    required property list<QtObject> windows

    signal dismissed

    onActiveChanged: {
        if (active) {
            armDelay.restart();
        } else {
            armDelay.stop();
            grab.active = false;
        }
    }

    HyprlandFocusGrab {
        id: grab

        active: false
        windows: root.windows
        onCleared: root.dismissed()
    }

    Timer {
        id: armDelay

        interval: 50
        onTriggered: grab.active = root.active
    }
}
