import QtQuick
import Quickshell
import qs.Modules.Bar
import qs.Modules.Dictation
import qs.Modules.Island
import qs.Modules.Notifications
import qs.Modules.Polkit
import qs.Modules.Screenshot
import qs.Modules.TooltipOverlay
import qs.Services

ShellRoot {
    readonly property var mediaControls: MediaControlService

    Bar {}

    NotificationManager {}

    ScreenshotOverlay {}

    ScreenshotToast {}

    ScreenshotEditor {}

    Island {}

    DictationPill {}

    PolkitDialog {}

    TooltipOverlay {}
}
