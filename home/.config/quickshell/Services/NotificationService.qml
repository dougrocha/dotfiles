pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

Singleton {
    id: root

    property list<var> history: []
    property list<var> notifications: []
    // Pointer over the popup stack keeps cards from expiring while being read.
    property bool hoverPaused: false
    property double pausedAt: 0

    // Shift timestamps on resume so paused cards keep their remaining time.
    onHoverPausedChanged: {
        if (hoverPaused) {
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

        // No timeout given: Critical stays, Low is brief, otherwise 3s.
        if (n.urgency === NotificationUrgency.Critical)
            return -1;
        if (n.urgency === NotificationUrgency.Low)
            return 2000;
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
            urgency: n.urgency,
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

    // replaces_id writes new content onto the same object; watch it so the snapshot redraws. Returns an unwatch.
    function watchForUpdates(notification, id) {
        const refresh = () => refreshSnapshot(notification, id);
        const signals = [notification.summaryChanged, notification.bodyChanged, notification.appNameChanged, notification.appIconChanged, notification.imageChanged, notification.actionsChanged];

        signals.forEach(signal => signal.connect(refresh));
        return () => signals.forEach(signal => signal.disconnect(refresh));
    }

    // Replace, not mutate, so the card redraws; keep the original timestamp.
    function refreshSnapshot(notification, id) {
        const index = root.notifications.findIndex(n => n.id === id);
        if (index === -1)
            return;

        const previous = root.notifications[index];
        const data = snapshot(notification, {
            timestamp: previous.timestamp,
            duration: previous.duration,
            isPopup: previous.isPopup
        });
        data.closeHandler = previous.closeHandler;
        data.unwatch = previous.unwatch;

        root.notifications = root.notifications.map((n, i) => i === index ? data : n);
    }

    function handleNotification(notification) {
        if (!notification.summary && !notification.body)
            return;

        notification.tracked = true;

        const id = notification.id;

        const existing = root.notifications.find(notif => notif.id === id);
        if (existing && existing.ref && existing.closeHandler)
            existing.ref.closed.disconnect(existing.closeHandler);
        if (existing && existing.unwatch)
            existing.unwatch();

        const metadata = {
            timestamp: Date.now(),
            duration: calculateDuration(notification),
            isPopup: true
        };

        const data = snapshot(notification, metadata);

        // "onClosed" would collide with the signal's slot, so it's named differently.
        const closeHandler = () => {
            notification.closed.disconnect(closeHandler);
            discardNotification(id);
        };
        notification.closed.connect(closeHandler);
        data.closeHandler = closeHandler;

        // Center is showing it, or DND: record to history instead of popping up. Critical always pops.
        if ((Visibilities.notificationCenter || SettingsService.doNotDisturb) && notification.urgency !== NotificationUrgency.Critical) {
            addToHistory(data);
            notification.expire();
            return;
        }

        data.unwatch = watchForUpdates(notification, id);

        // Restored twins carry different ids; drop a duplicate by content instead.
        root.notifications = [data, ...root.notifications.filter(notif => notif.id !== id && !(notif.restored && notif.appName === data.appName && notif.summary === data.summary && notif.body === data.body))];
    }

    // Live cards are dismissed server-side so the app is informed; the closed signal does bookkeeping.
    function removeNotification(notificationId) {
        const notif = root.notifications.find(n => n.id === notificationId);
        if (notif) {
            // A restored card has no server object; retire it here.
            if (notif.ref)
                notif.ref.dismiss();
            else
                discardNotification(notificationId);
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
        // Drop signal handlers before the C++ object dies.
        if (notif.unwatch)
            notif.unwatch();
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
            urgency: notification.urgency,
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
        onTriggered: historyFile.setText(JSON.stringify(root.history))
    }

    function parseArray(text) {
        try {
            const parsed = JSON.parse(text);
            return Array.isArray(parsed) ? parsed : null;
        } catch (e) {
            return null;
        }
    }

    // Under XDG_STATE_HOME, not Quickshell.cacheDir — that path is keyed by a hash of the shell's path.
    FileView {
        id: historyFile

        path: SettingsService.stateHome + "/quickshell/notifications.json"
        atomicWrites: true
        printErrors: false

        onLoaded: {
            const parsed = root.parseArray(text());
            if (parsed)
                root.history = parsed;
        }
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound)
                root.migrateLegacyHistory = true;
        }
    }

    // One-shot: adopt the history from the old cacheDir location, then rewrite at the new path.
    property bool migrateLegacyHistory: false

    // A config reload re-announces notifications; only a full restart drops them.
    // Restored cards are inert: their ref was a dead process's object, so actions are dropped.
    function liveSnapshot(n) {
        return {
            id: n.id,
            appName: n.appName,
            appIcon: n.appIcon,
            summary: n.summary,
            body: n.body,
            image: n.image,
            urgency: n.urgency,
            timestamp: n.timestamp,
            duration: n.duration
        };
    }

    function restoreLive(entries) {
        const now = Date.now();
        const usable = entries.filter(n => n.duration === -1 || (now - n.timestamp) < n.duration);

        root.notifications = [...usable.map(n => Object.assign({}, n, {
                    actions: [],
                    isPopup: true,
                    restored: true,
                    ref: null
                })), ...root.notifications];
    }

    Timer {
        id: liveSaveDebounce
        interval: 300
        repeat: false
        onTriggered: liveFile.setText(JSON.stringify(root.notifications.map(n => root.liveSnapshot(n))))
    }

    onNotificationsChanged: if (root.liveLoaded) liveSaveDebounce.restart()

    property bool liveLoaded: false

    FileView {
        id: liveFile

        path: SettingsService.stateHome + "/quickshell/notifications-live.json"
        atomicWrites: true
        printErrors: false

        onLoaded: {
            const parsed = root.parseArray(text());
            if (parsed)
                root.restoreLive(parsed);
            root.liveLoaded = true;
        }
        onLoadFailed: root.liveLoaded = true
    }

    FileView {
        path: root.migrateLegacyHistory ? Quickshell.cacheDir + "/notifications.json" : ""
        printErrors: false

        onLoaded: {
            const parsed = root.parseArray(text());
            if (parsed) {
                root.history = parsed;
                root.saveHistory();
            }
        }
    }

    Timer {
        interval: 100
        repeat: true
        running: notifications.length > 0
        onTriggered: {
            const now = Date.now();

            const expired = notifications.filter(notif => {
                return notif.duration !== -1 && !root.hoverPaused && (now - notif.timestamp) > notif.duration;
            });

            // Restored cards have no server object; retire them directly.
            expired.forEach(notif => notif.ref ? notif.ref.expire() : root.discardNotification(notif.id));
        }
    }
}
