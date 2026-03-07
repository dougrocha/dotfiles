pragma Singleton
import QtQml
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    // Filter out Cider - we handle Cider separately via CiderRpcService
    readonly property list<MprisPlayer> availablePlayers: Mpris.players.values.filter(p => p.identity !== "Cider")
    property MprisPlayer activePlayer: availablePlayers.find(p => p.isPlaying) ?? availablePlayers.find(p => p.canControl && p.canPlay) ?? null
}
