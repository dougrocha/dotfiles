pragma Singleton
import QtQml
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    function isBrowser(identity) {
        return (identity || "").toLowerCase().includes("chromium");
    }

    readonly property list<MprisPlayer> availablePlayers: Mpris.players.values.filter(p => p.identity !== "Cider" && !isBrowser(p.identity))

    readonly property MprisPlayer musicPlayer: {
        const playing = availablePlayers.find(p => p.isPlaying && (p.trackTitle || "") !== "");
        if (playing)
            return playing;
        return availablePlayers.find(p => (p.trackTitle || "") !== "") ?? null;
    }

    // Match a stream to its player by identity; the bus-name pid is the main process, not the audio child.
    function playerForBinary(binary) {
        if (!binary)
            return null;
        const wanted = binary.toLowerCase();
        return Mpris.players.values.find(p => (p.identity || "").toLowerCase() === wanted) ?? null;
    }

    // Only join on an artist so the separator doesn't dangle.
    function nowPlaying(title, artist) {
        const name = title || "";
        const by = artist || "";
        if (name === "")
            return "";
        return by !== "" ? name + " - " + by : name;
    }

    // Cider isn't on the session bus for us; its metadata comes from CiderRpcService.
    function nowPlayingFor(appName) {
        if (appName === "Cider")
            return nowPlaying(CiderRpcService.trackTitle, CiderRpcService.trackArtist);
        const player = playerForBinary(appName);
        return player ? nowPlaying(player.trackTitle, player.trackArtist) : "";
    }
}
