import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

import qs.Components
import qs.Constants

Repeater {
    model: 9

    Rectangle {
        property var workspace: {
            var ws = Hyprland.workspaces.values.find(function (w) {
                return w.id === index + 1;
            });
            return ws !== undefined ? ws : null;
        }
        property bool isActive: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id === (index + 1) : false
        property bool hasWindows: workspace !== null

        Layout.preferredWidth: 20
        Layout.preferredHeight: parent.height
        color: "transparent"

        visible: isActive || hasWindows

        Text {
            text: index + 1
            color: parent.isActive ? Colors.primary_fixed : (parent.hasWindows ? Colors.primary : Colors.outline)
            font.pixelSize: Fonts.p
            font.family: Fonts.font
            font.bold: true
            anchors.centerIn: parent
        }

        Rectangle {
            width: 20
            height: 3
            color: parent.isActive ? Colors.primary : Colors.surface
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
        }

        MouseArea {
            anchors.fill: parent
            onClicked: Hyprland.dispatch("workspace " + (index + 1))
        }
    }
}
