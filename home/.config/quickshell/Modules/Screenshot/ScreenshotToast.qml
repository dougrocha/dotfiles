pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Constants
import qs.Services

Variants {
    model: Desktop.primaryScreens

    delegate: PanelWindow {
        id: toastWindow

        required property var modelData
        screen: modelData

        color: "transparent"
        focusable: false

        WlrLayershell.namespace: "qs.screenshot_toast"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.exclusionMode: ExclusionMode.Ignore

        anchors {
            bottom: true
            right: true
        }

        implicitWidth: card.width + Theme.space.lg * 2
        implicitHeight: card.height + Theme.space.lg * 2

        visible: card.shown || card.Drag.active

        mask: Region {
            item: toastWindow.visible ? card : null
        }

        ScreenshotToastCard {
            id: card

            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: Theme.space.lg
        }
    }
}
