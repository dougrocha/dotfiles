pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import qs.Constants

Singleton {
    id: root

    readonly property list<var> popups: _popups.filter(n => !n.queued)
    readonly property int queuedCount: _popups.filter(n => n.queued).length
    readonly property list<var> history: _history

    function pause(): void {
        if (root._paused)
            return;
        root._paused = true;
        root._pausedAt = Date.now();
        root._armExpiry();
        root._saveLiveNow();
    }

    function resume(): void {
        if (!root._paused)
            return;
        root._paused = false;
        const now = Date.now();
        root._setPopups(root._popups.map(n => Object.assign({}, n, {
                expiresAt: n.expiresAt + root._pauseShift(root._pausedAt, n.timestamp, now)
            })));
    }

    function dismiss(id: var): void {
        const entry = root._live(id);
        root._close(entry, false);
    }

    function invokeAction(id: var, identifier: string): void {
        const actions = root._live(id)?.ref?.actions ?? [];
        actions.find(a => a.identifier === identifier)?.invoke();
    }

    function removeFromHistory(id: string): void {
        if (!root._history.some(n => n.id === id))
            return;
        root._setHistory(root._history.filter(n => n.id !== id));
    }

    function clearApp(app: string): void {
        root._setHistory(root._history.filter(n => root.appDisplayName(n.appName ?? "") !== app));
    }

    function clearHistory(): void {
        root._setHistory([]);
    }

    function appDisplayName(appName: string): string {
        if (!appName)
            return "Unknown";
        if (!Object.prototype.hasOwnProperty.call(root._appNames, appName)) {
            const entry = DesktopEntries.heuristicLookup(appName);
            root._appNames[appName] = entry?.name || appName.charAt(0).toUpperCase() + appName.slice(1);
        }
        return root._appNames[appName];
    }

    readonly property int _maxVisible: 5
    readonly property int _baseDuration: 5000
    readonly property int _actionDuration: 10000
    property list<var> _popups: []
    property list<var> _history: []
    property bool _paused: false
    property double _pausedAt: 0
    property bool _liveLoaded: false
    property bool _migrateLegacyHistory: false
    property var _islandWatchers: ({})
    property var _appNames: ({})
    readonly property string _session: Date.now().toString(36) + "-" + Math.random().toString(36).slice(2)
    property int _sequence: 0

    function _arrive(notification) {
        if (!notification.summary && !notification.body)
            return;
        notification.tracked = true;
        const id = notification.id;
        root._live(id)?.disconnect?.();

        const rule = SettingsService.notificationRule(notification.appName ?? "");
        if (rule.hide === true) {
            root._leave(id);
            notification.expire();
            return;
        }

        if (rule.mute !== true && root._progressOf(notification) >= 0) {
            root._leave(id);
            root._bridgeToIsland(notification);
            return;
        }

        const entry = root._entry(notification, Date.now(), root._duration(notification, rule));
        const centerOpen = Visibilities.isOpen(Visibilities.names.notifications);
        const dndBlocked = SettingsService.doNotDisturb && rule.allowDuringDnd !== true;

        if (rule.mute === true || ((centerOpen || dndBlocked) && notification.urgency !== NotificationUrgency.Critical)) {
            root._leave(id);
            root._addToHistory(entry);
            notification.expire();
            return;
        }

        entry.disconnect = root._watch(notification);
        root._popups.filter(n => n.restored && !n.leaving && n.appName === entry.appName && n.summary === entry.summary && n.body === entry.body).forEach(n => root._leave(n.id));
        if (root._popups.some(n => n.id === id))
            root._setPopups(root._popups.map(n => n.id === id ? entry : n));
        else
            root._setPopups([...root._popups, entry]);
    }

    function _refresh(id) {
        const previous = root._live(id);
        if (!previous?.ref)
            return;
        const entry = root._entry(previous.ref, previous.timestamp, previous.duration);
        entry.expiresAt = previous.expiresAt;
        entry.disconnect = previous.disconnect;
        root._setPopups(root._popups.map(n => n.id === id ? entry : n));
    }

    function _expireDue(now) {
        root._popups.filter(n => !n.leaving && !n.queued && root._expired(n, now)).forEach(n => root._close(n, true));
        root._armExpiry();
    }

    function _armExpiry() {
        expiryTimer.stop();
        if (root._paused)
            return;
        const times = root._popups.filter(n => !n.leaving && !n.queued && n.duration !== -1).map(n => n.expiresAt);
        if (times.length === 0)
            return;
        const delay = Math.min(...times) - Date.now();
        expiryTimer.interval = delay > 0 ? delay : 100;
        expiryTimer.start();
    }

    function _close(entry, expired) {
        if (!entry)
            return;
        if (!entry.ref)
            root._toHistory(entry.id);
        else if (expired)
            entry.ref.expire();
        else
            entry.ref.dismiss();
    }

    function _toHistory(id) {
        const entry = root._live(id);
        if (!entry)
            return;
        entry.disconnect?.();
        root._leave(id);
        root._addToHistory(entry);
    }

    function _leave(id) {
        if (!root._live(id))
            return;
        const now = Date.now();
        root._setPopups(root._popups.map(n => n.id === id && !n.leaving ? Object.assign({}, n, {
                leaving: true,
                leftUntil: now + Theme.motion.fast + 20,
                ref: null,
                disconnect: null
            }) : n));
        root._dropLeft(now);
    }

    function _dropLeft(now) {
        const kept = root._popups.filter(n => !n.leaving || n.leftUntil > now);
        if (kept.length !== root._popups.length)
            root._setPopups(kept);
        const next = Math.min(...kept.filter(n => n.leaving).map(n => n.leftUntil));
        if (!isFinite(next))
            return;
        dropTimer.interval = Math.max(1, next - now);
        dropTimer.restart();
    }

    function _restore(saved, now) {
        const kept = saved.map(n => Object.assign({}, n, {
                id: "restored-" + root._historyId(),
                expiresAt: root._restoredExpiry(n, now),
                actions: [],
                leaving: false,
                restored: true,
                ref: null
            })).filter(n => !root._expired(n, now));
        root._setPopups([...kept, ...root._popups]);
    }

    function _addToHistory(entry) {
        if (!entry.summary && !entry.body)
            return;
        const item = {
            id: root._historyId(),
            appName: entry.appName ?? "",
            appIcon: entry.appIcon ?? "",
            summary: entry.summary ?? "",
            body: entry.body ?? "",
            urgency: entry.urgency,
            timestamp: entry.timestamp ?? Date.now()
        };
        root._setHistory([item, ...root._history].slice(0, 50));
    }

    function _live(id) {
        return root._popups.find(n => n.id === id && !n.leaving) ?? null;
    }

    function _setPopups(next) {
        const now = Date.now();
        let shown = 0;
        root._popups = next.map(n => {
            if (n.leaving)
                return n;
            shown += 1;
            const queued = shown > root._maxVisible;
            if (queued === (n.queued === true))
                return n;
            return Object.assign({}, n, queued ? {
                queued: true
            } : {
                queued: false,
                expiresAt: now + n.duration
            });
        });
        root._armExpiry();
        if (root._liveLoaded)
            liveSave.restart();
    }

    function _setHistory(next) {
        root._history = next;
        historySave.restart();
    }

    function _saveLiveNow() {
        if (!root._liveLoaded)
            return;
        liveSave.stop();
        liveFile.setText(root._liveJson());
    }

    function _liveJson() {
        return JSON.stringify(root._popups.filter(n => !n.leaving).map(n => ({
                    id: n.id,
                    appName: n.appName,
                    appIcon: n.appIcon,
                    summary: n.summary,
                    body: n.body,
                    image: n.image,
                    urgency: n.urgency,
                    timestamp: n.timestamp,
                    duration: n.duration,
                    expiresAt: n.expiresAt,
                    pausedAt: root._paused ? root._pausedAt : null
                })));
    }

    function _entry(notification, timestamp, duration) {
        return {
            id: notification.id,
            appName: notification.appName ?? "",
            appIcon: notification.appIcon ?? "",
            summary: notification.summary ?? "",
            body: notification.body ?? "",
            image: notification.image ?? "",
            urgency: notification.urgency,
            actions: (notification.actions ?? []).map(a => ({
                        identifier: a.identifier,
                        text: a.text
                    })),
            timestamp: timestamp,
            duration: duration,
            expiresAt: timestamp + duration,
            leaving: false,
            ref: notification
        };
    }

    function _watch(notification) {
        const id = notification.id;
        const update = () => root._refresh(id);
        const refresh = () => Qt.callLater(update);
        const close = () => root._toHistory(id);
        const updates = [notification.summaryChanged, notification.bodyChanged, notification.appNameChanged, notification.appIconChanged, notification.imageChanged, notification.actionsChanged];
        updates.forEach(signal => signal.connect(refresh));
        notification.closed.connect(close);
        return () => {
            updates.forEach(signal => signal.disconnect(refresh));
            notification.closed.disconnect(close);
        };
    }

    function _bridgeToIsland(notification) {
        const id = notification.id;
        const alertId = "notification-" + id;
        const signals = [notification.hintsChanged, notification.summaryChanged];
        root._islandWatchers[id]?.();

        function update() {
            const progress = root._progressOf(notification);
            const label = notification.summary || root.appDisplayName(notification.appName);
            if (progress >= 1)
                IslandService.pushAlert(alertId, "checkCircle", label, 2);
            else if (progress >= 0)
                IslandService.setAlert(alertId, "", label, notification.expireTimeout > 0 ? notification.expireTimeout / 1000 : 0, progress);
        }

        function unwatch() {
            signals.forEach(signal => signal.disconnect(update));
            notification.closed.disconnect(close);
            delete root._islandWatchers[id];
        }

        function close() {
            unwatch();
            if (IslandService.alerts.some(a => a.id === alertId && a.progress >= 0))
                IslandService.clearAlert(alertId);
        }

        signals.forEach(signal => signal.connect(update));
        notification.closed.connect(close);
        root._islandWatchers[id] = unwatch;
        update();
    }

    function _duration(notification, rule) {
        if (typeof rule?.timeoutMs === "number" && isFinite(rule.timeoutMs) && rule.timeoutMs >= 0)
            return rule.timeoutMs === 0 ? -1 : Math.round(rule.timeoutMs);
        if (notification.expireTimeout === 0)
            return -1;
        if (notification.expireTimeout > 0)
            return notification.expireTimeout;
        if (notification.urgency === NotificationUrgency.Critical)
            return -1;
        if (notification.urgency === NotificationUrgency.Low)
            return Math.round(root._baseDuration * 2 / 3);
        if ((notification.actions ?? []).length > 0)
            return Math.max(root._baseDuration, root._actionDuration);
        return root._baseDuration;
    }

    function _expired(entry, now) {
        return entry.duration !== -1 && now >= entry.expiresAt;
    }

    function _pauseShift(pausedAt, timestamp, now) {
        return Math.max(0, now - Math.max(pausedAt, timestamp));
    }

    function _restoredExpiry(saved, now) {
        const expiresAt = saved.expiresAt ?? (saved.timestamp + saved.duration);
        return expiresAt + (typeof saved.pausedAt === "number" ? root._pauseShift(saved.pausedAt, saved.timestamp, now) : 0);
    }

    function _progressOf(notification) {
        const value = notification.hints?.value;
        return typeof value === "number" ? Math.max(0, Math.min(100, value)) / 100 : -1;
    }

    function _historyId() {
        return "history-" + root._session + "-" + (++root._sequence);
    }

    function _loadHistory(text) {
        const entries = root._parseArray(text);
        if (entries)
            root._setHistory(entries.map(n => Object.assign({}, n, {
                    id: root._historyId()
                })));
        return entries !== null;
    }

    function _parseArray(text) {
        try {
            const parsed = JSON.parse(text);
            return Array.isArray(parsed) ? parsed : null;
        } catch (e) {
            return null;
        }
    }

    NotificationServer {
        keepOnReload: false
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        imageSupported: true
        extraHints: ["value"]

        onNotification: notification => root._arrive(notification)
    }

    Timer {
        id: expiryTimer
        onTriggered: root._expireDue(Date.now())
    }

    Connections {
        target: DesktopEntries.applications

        function onValuesChanged() {
            root._appNames = {};
        }
    }

    Timer {
        id: dropTimer
        onTriggered: root._dropLeft(Date.now())
    }

    Timer {
        id: historySave
        interval: 300
        onTriggered: historyFile.setText(JSON.stringify(root._history))
    }

    Timer {
        id: liveSave
        interval: 300
        onTriggered: liveFile.setText(root._liveJson())
    }

    FileView {
        id: historyFile

        path: SettingsService.stateHome + "/quickshell/notifications.json"
        atomicWrites: true
        printErrors: false

        onLoaded: root._loadHistory(text())
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound)
                root._migrateLegacyHistory = true;
        }
    }

    FileView {
        path: root._migrateLegacyHistory ? Quickshell.cacheDir + "/notifications.json" : ""
        printErrors: false

        onLoaded: {
            if (root._loadHistory(text()))
                historySave.restart();
        }
    }

    FileView {
        id: liveFile

        path: SettingsService.stateHome + "/quickshell/notifications-live.json"
        atomicWrites: true
        printErrors: false

        onLoaded: {
            const saved = root._parseArray(text());
            if (saved)
                root._restore(saved, Date.now());
            root._liveLoaded = true;
            if (saved || root._popups.length > 0)
                liveSave.restart();
        }
        onLoadFailed: {
            root._liveLoaded = true;
            if (root._popups.length > 0)
                liveSave.restart();
        }
    }
}
