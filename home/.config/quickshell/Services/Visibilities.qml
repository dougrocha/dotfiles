pragma Singleton
import QtQml
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool musicPanel: false
    property bool settingsPanel: false
    property bool soundPanel: false
    property bool bluetoothPanel: false
    property bool notificationCenter: false
    // Keybound: reveal the bar over fullscreen when the hover strip is unreachable.
    property bool barPinned: false
    // Mirrors the bar's reveal so the island overlay slides in sync.
    property bool barRevealed: true

    // Tray menus are one popup per item, so they listen for this.
    signal closeTrayMenus

    // Any bar action closes whatever popup is open.
    function closePopups() {
        musicPanel = false;
        settingsPanel = false;
        soundPanel = false;
        bluetoothPanel = false;
        notificationCenter = false;
        closeTrayMenus();
    }
    function openSettings() {
        closePopups();
        settingsPanel = true;
    }
    function toggleSettings() {
        settingsPanel ? (settingsPanel = false) : openSettings();
    }
    function openSoundPanel() {
        closePopups();
        soundPanel = true;
    }
    function toggleSoundPanel() {
        soundPanel ? (soundPanel = false) : openSoundPanel();
    }
    function openBluetoothPanel() {
        closePopups();
        bluetoothPanel = true;
    }
    function toggleBluetoothPanel() {
        bluetoothPanel ? (bluetoothPanel = false) : openBluetoothPanel();
    }
    function openNotificationCenter() {
        closePopups();
        notificationCenter = true;
    }
    function toggleNotificationCenter() {
        notificationCenter ? (notificationCenter = false) : openNotificationCenter();
    }
    // Idempotent: re-opening resets the island's calendar.
    function openMusicPanel() {
        if (musicPanel)
            return;
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
        target: "sound-panel"
        function show(): void {
            root.openSoundPanel();
        }
        function hide(): void {
            root.soundPanel = false;
        }
        function toggle(): void {
            root.toggleSoundPanel();
        }
    }

    IpcHandler {
        target: "bluetooth-panel"
        function show(): void {
            root.openBluetoothPanel();
        }
        function hide(): void {
            root.bluetoothPanel = false;
        }
        function toggle(): void {
            root.toggleBluetoothPanel();
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
