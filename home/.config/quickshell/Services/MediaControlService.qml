import QtQml
import Quickshell
pragma Singleton

Singleton {
    id: root

    function shouldUseCiderRpc() {
        return CiderRpcService.isOnline;
    }

    // Control: Next track
    function next() {
        if (shouldUseCiderRpc()) {
            console.log("[MediaControl] Routing next() to CiderRPC");
            CiderRpcService.next();
        } else {
            console.log("[MediaControl] Routing next() to MPRIS");
            MprisService.activePlayer?.next();
        }
    }

    // Control: Previous track (or restart if past 3 seconds)
    function previous() {
        if (shouldUseCiderRpc()) {
            if (CiderRpcService.position > 3) {
                // Past 3 seconds - restart the song
                CiderRpcService.seek(0);
            } else {
                // Before 3 seconds - go to previous track
                CiderRpcService.previous();
            }
        } else {
            console.log("[MediaControl] Routing previous() to MPRIS");
            MprisService.activePlayer?.previous();
        }
    }

    // Control: Pause
    function pause() {
        if (shouldUseCiderRpc()) {
            console.log("[MediaControl] Routing pause() to CiderRPC");
            CiderRpcService.pause();
        } else {
            console.log("[MediaControl] Routing pause() to MPRIS");
            MprisService.activePlayer?.pause();
        }
    }

    // Control: Play
    function play() {
        if (shouldUseCiderRpc()) {
            console.log("[MediaControl] Routing play() to CiderRPC");
            CiderRpcService.play();
        } else {
            console.log("[MediaControl] Routing play() to MPRIS");
            MprisService.activePlayer?.play();
        }
    }

    // Control: Play/Pause toggle
    function playpause() {
        if (shouldUseCiderRpc()) {
            console.log("[MediaControl] Routing playpause() to CiderRPC");
            CiderRpcService.playpause();
        } else {
            console.log("[MediaControl] Routing playpause() to MPRIS");
            MprisService.activePlayer?.togglePlaying();
        }
    }

    // Control: Seek to position
    function seek(seconds) {
        if (shouldUseCiderRpc()) {
            console.log("[MediaControl] Routing seek() to CiderRPC");
            CiderRpcService.seek(seconds);
        } else {
            console.log("[MediaControl] Routing seek() to MPRIS");
            if (MprisService.activePlayer) {
                MprisService.activePlayer.position = seconds * 1000000;  // Convert to microseconds
            }
        }
    }
}
