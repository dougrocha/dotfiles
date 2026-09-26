pragma Singleton
import QtQml
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    function isBrowser(identity) {
        return (identity || "").toLowerCase().includes("chromium");
    }

    function isProxy(player) {
        return (player.dbusName || "").endsWith(".playerctld");
    }

    function hasTrack(player) {
        return (player?.trackTitle || "") !== "";
    }

    readonly property list<MprisPlayer> availablePlayers: Mpris.players.values.filter(p => !isBrowser(p.identity) && !isProxy(p))
    readonly property list<MprisPlayer> browserPlayers: Mpris.players.values.filter(p => isBrowser(p.identity) && !isProxy(p))

    // Music apps win over browsers, so a background video never hides Cider
    readonly property MprisPlayer playingPlayer: availablePlayers.find(p => p.isPlaying && hasTrack(p)) ?? browserPlayers.find(p => p.isPlaying && hasTrack(p)) ?? null

    // Keep the last player that played so pausing it doesn't swap the island to another app
    property MprisPlayer lastPlayer: null
    onPlayingPlayerChanged: if (playingPlayer)
        lastPlayer = playingPlayer

    readonly property MprisPlayer musicPlayer: playingPlayer ?? (hasTrack(lastPlayer) ? lastPlayer : null) ?? availablePlayers.find(p => hasTrack(p)) ?? null
    readonly property bool musicPlayerIsBrowser: isBrowser(musicPlayer?.identity)

    function playerForBinary(binary) {
        if (!binary)
            return null;
        const wanted = binary.toLowerCase();
        return Mpris.players.values.find(p => (p.identity || "").toLowerCase() === wanted) ?? null;
    }

    function nowPlaying(title, artist) {
        const name = title || "";
        const by = artist || "";
        if (name === "")
            return "";
        return by !== "" ? name + " - " + by : name;
    }

    function nowPlayingFor(appName) {
        const player = playerForBinary(appName);
        return player ? nowPlaying(player.trackTitle, player.trackArtist) : "";
    }
}
