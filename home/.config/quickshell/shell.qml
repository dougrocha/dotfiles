//@ pragma UseQApplication
import qs.Modules.Bar
import qs.Components
import qs.Services
import qs.Widgets
import QtQuick
import QtQuick.Controls
import Quickshell

ShellRoot {
    id: root

    Variants {
        model: Quickshell.screens

        Bar {}
    }
}
