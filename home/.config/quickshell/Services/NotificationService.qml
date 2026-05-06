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
        notification.tracked = true;

        const id = notification.id;

        const metadata = {
            timestamp: Date.now(),
            duration: calculateDuration(notification),
            isPopup: true
        };

        const data = Object.assign(notification, metadata);

        root.notifications.unshift(data);

        notification.closed.connect(() => {
            removeNotification(id);
        });
    }

    function removeNotification(notificationId) {
        const popupIndex = root.notifications.findIndex(notif => notif.id === notificationId);
        if (popupIndex !== -1) {
            const notif = root.notifications[popupIndex];
            notif.isPopup = false;
            root.notifications.splice(popupIndex, 1);
            addToHistory(notif);
            return;
        }

        const historyIndex = root.history.findIndex(notif => notif.id === notificationId);
        if (historyIndex !== -1)
            root.history.splice(historyIndex, 1);
    }

    function addToHistory(notification) {
        root.history.unshift(notification);
        if (root.history.length > 20)
            root.history.pop();
    }

    function clearHistory() {
        root.history = [];
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
