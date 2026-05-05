pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

Singleton {
    id: root

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
            duration: calculateDuration(notification)
        };

        const data = Object.assign(notification, metadata);

        root.notifications.unshift(data);

        notification.closed.connect(() => {
            removeNotification(id);
        });
    }

    function removeNotification(notificationId) {
        const index = root.notifications.findIndex(notif => notif.id === notificationId);
        if (index !== -1)
            root.notifications.splice(index, 1);
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
