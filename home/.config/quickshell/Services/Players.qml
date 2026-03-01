import QtQuick
import Quickshell
import Quickshell.Services.Mpris
pragma Singleton

Singleton {
    id: root

    readonly property var list: Mpris.players.values ?? []
    property var active: {
        // Find the first playing player
        if (!list || list.length === 0)
            return null;

        for (var i = 0; i < list.length; i++) {
            if (list[i] && list[i].isPlaying)
                return list[i];

        }
        return list[0] ?? null;
    }

    function getIdentity(player) {
        return player ? (player.identity || "Unknown") : "Unknown";
    }

    function updateActivePlayer() {
        if (!list || list.length === 0) {
            active = null;
            return ;
        }
        var newActive = null;
        // Find the first playing player
        for (var i = 0; i < list.length; i++) {
            if (list[i] && list[i].isPlaying) {
                newActive = list[i];
                break;
            }
        }
        // If no player is playing, use first one
        if (!newActive && list.length > 0)
            newActive = list[0];

        // Update active if changed
        if (active !== newActive)
            active = newActive;

    }

    Connections {
        function onValuesChanged() {
            root.updateActivePlayer();
        }

        target: Mpris.players
    }

    Timer {
        interval: 2000
        running: list && list.length > 0
        repeat: true
        triggeredOnStart: true
        onTriggered: root.updateActivePlayer()
    }

}
