//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma Env QT_QPA_PLATFORMTHEME=

import qs.Modules.Bar
import qs.Modules.Notifications
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
}
