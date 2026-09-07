pragma Singleton
import QtQml
import Quickshell

Singleton {
    id: root

    function next() {
        MprisService.musicPlayer?.next();
    }

    function previous() {
        const player = MprisService.musicPlayer;
        if (!player)
            return;
        if (player.position > 3)
            root.seek(0);
        else
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
        if (MprisService.musicPlayer)
            MprisService.musicPlayer.position = seconds;
    }
}
