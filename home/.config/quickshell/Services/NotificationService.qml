pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import qs.Constants

Singleton {
    id: root

    property list<var> history: []
    property list<var> notifications: []
    property bool stackPaused: false
    property double pausedAt: 0

    // Pausing only stops dismissal; timestamps keep aging. Shift them by the
    // paused duration on resume so cards get their remaining time back
    // instead of all expiring at once.
    onStackPausedChanged: {
        if (stackPaused) {
            pausedAt = Date.now();
        } else {
            const delta = Date.now() - pausedAt;
            root.notifications.forEach(n => n.timestamp += delta);
        }
    }

    NotificationServer {
        keepOnReload: false
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        imageSupported: true

        onNotification: notification => handleNotification(notification)
    }

    function calculateDuration(n) {
        // stay forever
        if (n.expireTimeout === 0) {
            return -1;
        }

        // app decides
        if (n.expireTimeout > 0) {
            return n.expireTimeout;
        }

        // 3 second default
        return 3000;
    }

    function snapshot(n, metadata) {
        return {
            id: n.id,
            appName: n.appName ?? "",
            appIcon: n.appIcon ?? "",
            summary: n.summary ?? "",
            body: n.body ?? "",
            image: n.image ?? "",
            actions: (n.actions ?? []).map(a => ({
                        identifier: a.identifier,
                        text: a.text,
                        invoke: () => a.invoke()
                    })),
            timestamp: metadata.timestamp,
            duration: metadata.duration,
            isPopup: metadata.isPopup,
            ref: n
        };
    }

    function handleNotification(notification) {
        if (!notification.summary && !notification.body)
            return;

        notification.tracked = true;

        const id = notification.id;

        const existing = root.notifications.find(notif => notif.id === id);
        if (existing && existing.closeHandler)
            existing.ref.closed.disconnect(existing.closeHandler);

        const metadata = {
            timestamp: Date.now(),
            duration: calculateDuration(notification),
            isPopup: true
        };

        const data = snapshot(notification, metadata);

        // "onClosed" would collide with the closed signal's handler slot, so
        // the stashed callback needs a different name.
        const closeHandler = () => {
            notification.closed.disconnect(closeHandler);
            discardNotification(id);
        };
        notification.closed.connect(closeHandler);
        data.closeHandler = closeHandler;

        if (Visibilities.notificationCenter) {
            addToHistory(data);
            notification.expire();
            return;
        }

        root.notifications = [data, ...root.notifications.filter(notif => notif.id !== id)];
    }

    // User- or UI-initiated removal. Live notifications are dismissed
    // server-side so the sending app is informed; the closed signal then
    // drives the actual bookkeeping.
    function removeNotification(notificationId) {
        const notif = root.notifications.find(n => n.id === notificationId);
        if (notif) {
            notif.ref.dismiss();
            return;
        }

        if (root.history.some(n => n.id === notificationId)) {
            root.history = root.history.filter(n => n.id !== notificationId);
            saveHistory();
        }
    }

    // Runs when the server reports a notification closed, whatever the cause.
    function discardNotification(notificationId) {
        const notif = root.notifications.find(n => n.id === notificationId);
        if (!notif)
            return;
        notif.isPopup = false;
        root.notifications = root.notifications.filter(n => n.id !== notificationId);
        addToHistory(notif);
    }

    function addToHistory(notification) {
        if (!notification.summary && !notification.body)
            return;
        const entry = {
            id: notification.id,
            appName: notification.appName ?? "",
            appIcon: notification.appIcon ?? "",
            summary: notification.summary ?? "",
            body: notification.body ?? "",
            timestamp: notification.timestamp ?? Date.now()
        };
        root.history = [entry, ...root.history.filter(n => n.id !== entry.id)].slice(0, 50);
        saveHistory();
    }

    function clearAppHistory(appName) {
        root.history = root.history.filter(n => (n.appName || "Unknown") !== appName);
        saveHistory();
    }

    function clearHistory() {
        root.history = [];
        saveHistory();
    }

    function saveHistory() {
        saveDebounce.restart();
    }

    Timer {
        id: saveDebounce
        interval: 300
        repeat: false
        onTriggered: {
            saveProcess.json = JSON.stringify(root.history);
            saveProcess.running = true;
        }
    }

    FileView {
        path: Theme.notifications.historyPath
        onLoaded: {
            try {
                const parsed = JSON.parse(text());
                if (Array.isArray(parsed))
                    root.history = parsed;
            } catch (e) {}
        }
    }

    Process {
        id: saveProcess
        property string json: ""
        command: ["sh", "-c", `mkdir -p "${Quickshell.cacheDir}" && printf '%s' "$QS_NOTIF" > "${Theme.notifications.historyPath}"`]
        environment: ({
                "QS_NOTIF": json
            })
        running: false
    }

    Timer {
        interval: 100
        repeat: true
        running: notifications.length > 0
        onTriggered: {
            const now = Date.now();

            const expired = notifications.filter(notif => {
                return notif.duration !== -1 && !root.stackPaused && (now - notif.timestamp) > notif.duration;
            });

            expired.forEach(notif => notif.ref.expire());
        }
    }
}
