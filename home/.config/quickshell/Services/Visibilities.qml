pragma Singleton
import QtQml
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool musicPanel: false
    property bool settingsPanel: false
    property bool notificationCenter: false
    // Keeps the bar revealed over a fullscreen window; games that constrain
    // the pointer make the hover strip unreachable, so this is keybound.
    property bool barPinned: false

    // Any bar action — opening another popup, launching an app, switching
    // workspace — closes whatever popup is open.
    function closePopups() {
        musicPanel = false;
        settingsPanel = false;
        notificationCenter = false;
    }
    function openSettings() {
        closePopups();
        settingsPanel = true;
    }
    function toggleSettings() {
        settingsPanel ? (settingsPanel = false) : openSettings();
    }
    function openNotificationCenter() {
        closePopups();
        notificationCenter = true;
    }
    function toggleNotificationCenter() {
        notificationCenter ? (notificationCenter = false) : openNotificationCenter();
    }
    function openMusicPanel() {
        closePopups();
        musicPanel = true;
    }
    function toggleMusicPanel() {
        musicPanel ? (musicPanel = false) : openMusicPanel();
    }

    IpcHandler {
        target: "music-panel"
        function show(): void {
            root.openMusicPanel();
        }
        function hide(): void {
            root.musicPanel = false;
        }
        function toggle(): void {
            root.toggleMusicPanel();
        }
    }

    IpcHandler {
        target: "settings-panel"
        function show(): void {
            root.openSettings();
        }
        function hide(): void {
            root.settingsPanel = false;
        }
        function toggle(): void {
            root.toggleSettings();
        }
    }

    IpcHandler {
        target: "top-bar"
        function show(): void {
            root.barPinned = true;
        }
        function hide(): void {
            root.barPinned = false;
        }
        function toggle(): void {
            root.barPinned = !root.barPinned;
        }
    }

    IpcHandler {
        target: "notification-center"
        function show(): void {
            root.openNotificationCenter();
        }
        function hide(): void {
            root.notificationCenter = false;
        }
        function toggle(): void {
            root.toggleNotificationCenter();
        }
    }
}
