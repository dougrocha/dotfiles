pragma Singleton
pragma ComponentBehavior: Bound

import QtQml
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property bool revealed: revealedOn(Desktop.primaryScreen)

    property bool _pinned: false

    function revealedOn(screen: var): bool {
        return _stateFor(screen)?.revealed ?? true;
    }

    function setHovered(screen: var, hovered: bool): void {
        const state = _stateFor(screen);
        if (state)
            state.hovered = hovered;
    }

    function _stateFor(screen) {
        return screens.instances.find(state => state.modelData === screen) ?? null;
    }

    Variants {
        id: screens
        model: Quickshell.screens

        delegate: Scope {
            id: state

            required property var modelData
            readonly property string kind: Desktop.fullscreenKind(modelData)
            readonly property bool autoHide: kind !== "none"
            readonly property bool held: Visibilities.anyOpen || root._pinned
            readonly property bool wanted: !autoHide || hovered || held
            property bool hovered: false
            property bool revealed: true

            onRevealedChanged: placeWindow()
            onKindChanged: placeWindow()

            onAutoHideChanged: {
                if (autoHide && !hovered && !held) {
                    hideTimer.stop();
                    revealed = false;
                }
            }

            onWantedChanged: {
                hideTimer.stop();
                revealTimer.stop();
                if (!wanted)
                    hideTimer.restart();
                else if (autoHide && !held)
                    revealTimer.restart();
                else
                    revealed = true;
            }

            function placeWindow() {
                if (kind === "windowed")
                    Desktop.placeFullscreen(modelData, revealed);
            }

            Timer {
                id: revealTimer
                interval: 250
                onTriggered: state.revealed = true
            }

            Timer {
                id: hideTimer
                interval: 1000
                onTriggered: state.revealed = false
            }
        }
    }

    IpcHandler {
        target: "top-bar"

        function pin(): void {
            root._pinned = true;
        }
        function unpin(): void {
            root._pinned = false;
        }
        function toggle(): void {
            root._pinned = !root._pinned;
        }
    }
}
