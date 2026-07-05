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

    function handleNotification(notification) {
        if (!notification.summary && !notification.body)
            return;

        notification.tracked = true;

        const id = notification.id;

        const existing = root.notifications.find(notif => notif.id === id);
        if (existing && existing.onClosed)
            notification.closed.disconnect(existing.onClosed);

        const metadata = {
            timestamp: Date.now(),
            duration: calculateDuration(notification),
            isPopup: true
        };

        const data = Object.assign(notification, metadata);

        const onClosed = () => {
            notification.closed.disconnect(onClosed);
            removeNotification(id);
        };
        notification.closed.connect(onClosed);
        data.onClosed = onClosed;

        if (Visibilities.notificationCenter) {
            addToHistory(data);
            return;
        }

        root.notifications = [data, ...root.notifications.filter(notif => notif.id !== id)];
    }

    function removeNotification(notificationId) {
        const notif = root.notifications.find(n => n.id === notificationId);
        if (notif) {
            notif.isPopup = false;
            root.notifications = root.notifications.filter(n => n.id !== notificationId);
            addToHistory(notif);
            return;
        }

        if (root.history.some(n => n.id === notificationId)) {
            root.history = root.history.filter(n => n.id !== notificationId);
            saveHistory();
        }
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
            timestamp: notification.timestamp ?? Date.now(),
            actions: (notification.actions ?? []).filter(a => a.identifier !== "default" && a.text !== "").map(a => ({
                        identifier: a.identifier,
                        text: a.text
                    }))
        };
        root.history = [entry, ...root.history.filter(n => n.id !== entry.id)].slice(0, 10);
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

            expired.forEach(notif => removeNotification(notif.id));
        }
    }
}
