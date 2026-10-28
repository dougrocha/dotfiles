import QtQuick
import QtQuick.Controls
import Quickshell
import qs.Components
import qs.Modules.Bar
import qs.Modules.Dictation
import qs.Modules.Island
import qs.Modules.Notifications
import qs.Modules.Polkit
import qs.Modules.Screenshot
import qs.Modules.TooltipOverlay
import qs.Services
import qs.Widgets

ShellRoot {
    id: root

    readonly property var mediaControls: MediaControlService

    Bar {}

    NotificationManager {}

    ScreenshotManager {}

    ScreenshotToast {}

    ScreenshotEditor {}

    Island {}

    DictationPill {}

    PolkitAgent {}

    TooltipOverlay {}
}
