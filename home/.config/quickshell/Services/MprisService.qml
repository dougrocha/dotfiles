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

    readonly property list<MprisPlayer> availablePlayers: Mpris.players.values.filter(p => !isBrowser(p.identity) && !isProxy(p))

    readonly property MprisPlayer musicPlayer: {
        const playing = availablePlayers.find(p => p.isPlaying && (p.trackTitle || "") !== "");
        if (playing)
            return playing;
        return availablePlayers.find(p => (p.trackTitle || "") !== "") ?? null;
    }

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
