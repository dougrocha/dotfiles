import qs.Modules.Bar
import qs.Modules.Island
import qs.Modules.Notifications
import qs.Modules.Polkit
import qs.Modules.Screenshot
import qs.Modules.TooltipOverlay
import qs.Components
import qs.Services
import qs.Widgets
import QtQuick
import QtQuick.Controls
import Quickshell

ShellRoot {
    id: root

    Bar {}

    NotificationManager {}

    ScreenshotManager {}

    ScreenshotToast {}

    Island {}

    PolkitAgent {}

    TooltipOverlay {}
}
