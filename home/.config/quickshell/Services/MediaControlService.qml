pragma Singleton
import QtQml
import Quickshell

Singleton {
    id: root

    function shouldUseCiderRpc() {
        return CiderRpcService.isOnline;
    }

    function next() {
        if (shouldUseCiderRpc()) {
            CiderRpcService.next();
        } else {
            MprisService.musicPlayer?.next();
        }
    }

    function previous() {
        if (shouldUseCiderRpc()) {
            // Past 3 seconds, restart the song instead of skipping to the previous track.
            if (CiderRpcService.position > 3) {
                CiderRpcService.seek(0);
            } else {
                CiderRpcService.previous();
            }
        } else {
            MprisService.musicPlayer?.previous();
        }
    }

    function pause() {
        if (shouldUseCiderRpc()) {
            CiderRpcService.pause();
        } else {
            MprisService.musicPlayer?.pause();
        }
    }

    function play() {
        if (shouldUseCiderRpc()) {
            CiderRpcService.play();
        } else {
            MprisService.musicPlayer?.play();
        }
    }

    function playpause() {
        if (shouldUseCiderRpc()) {
            CiderRpcService.playpause();
        } else {
            MprisService.musicPlayer?.togglePlaying();
        }
    }

    function seek(seconds) {
        if (shouldUseCiderRpc()) {
            CiderRpcService.seek(seconds);
        } else if (MprisService.musicPlayer) {
            MprisService.musicPlayer.position = seconds * 1000000; // Convert to microseconds
        }
    }
}
