pragma Singleton
import QtQml
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    IpcHandler {
        target: "music-control"

        function next(): void {
            root.next();
        }

        function previous(): void {
            root.previous();
        }

        function playpause(): void {
            root.playpause();
        }
    }

    function next() {
        const player = MprisService.musicPlayer;
        if (player?.canGoNext)
            player.next();
    }

    function previous() {
        const player = MprisService.musicPlayer;
        if (!player)
            return;
        if (player.position > 3)
            root.seek(0);
        else if (player.canGoPrevious)
            player.previous();
    }

    function pause() {
        MprisService.musicPlayer?.pause();
    }

    function play() {
        MprisService.musicPlayer?.play();
    }

    function playpause() {
        MprisService.musicPlayer?.togglePlaying();
    }

    function seek(seconds) {
        const player = MprisService.musicPlayer;
        if (!player)
            return;
        if (player.lengthSupported && player.length > 0 && seconds >= player.length - 1) {
            root.next();
            return;
        }
        player.position = Math.max(0, seconds);
    }
}
