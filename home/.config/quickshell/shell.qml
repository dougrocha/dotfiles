import "./Components"
import "./Modules"
import "./Services"
import "./Widgets"
import QtQuick
import QtQuick.Controls
import Quickshell

ShellRoot {
    id: root

    Variants {
        model: Quickshell.screens

        Panel {}
    }
}
