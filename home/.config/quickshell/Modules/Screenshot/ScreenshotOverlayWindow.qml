pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Services

PanelWindow {
    id: overlayWindow

    required property var modelData
    readonly property real desktopOriginX: ScreenshotSession.desktop.left
    readonly property real desktopOriginY: ScreenshotSession.desktop.top
    readonly property real outputX: modelData.x - desktopOriginX
    readonly property real outputY: modelData.y - desktopOriginY
    readonly property bool hostsToolbar: ScreenshotSession.showsToolbarOn(modelData.name)

    screen: modelData
    visible: ScreenshotSession.overlayVisible
    color: "transparent"
    implicitWidth: ScreenshotSession.desktop.width
    implicitHeight: ScreenshotSession.desktop.height
    WlrLayershell.margins.left: ScreenshotSession.desktop.left - modelData.x
    WlrLayershell.margins.top: ScreenshotSession.desktop.top - modelData.y
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs.screenshot_overlay"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    anchors.top: true
    anchors.left: true

    onVisibleChanged: {
        if (visible)
            keyHandler.forceActiveFocus();
    }

    MouseArea {
        anchors.fill: parent
        enabled: ScreenshotSession.overlayVisible
        hoverEnabled: true
        cursorShape: ScreenshotSession.cursorShape
        onEntered: ScreenshotSession.hoverAt(overlayWindow.desktopOriginX + mouseX, overlayWindow.desktopOriginY + mouseY)
        onPressed: mouse => {
            keyHandler.forceActiveFocus();
            ScreenshotSession.beginDrag(overlayWindow.desktopOriginX + mouse.x, overlayWindow.desktopOriginY + mouse.y);
        }
        onPositionChanged: mouse => {
            const x = overlayWindow.desktopOriginX + mouse.x;
            const y = overlayWindow.desktopOriginY + mouse.y;
            if (pressed)
                ScreenshotSession.dragTo(x, y);
            else
                ScreenshotSession.hoverAt(x, y);
        }
        onReleased: ScreenshotSession.endDrag()
        onCanceled: ScreenshotSession.cancelDrag()
        onExited: ScreenshotSession.pointerLeft()
    }

    ScreenshotOverlayVisuals {
        x: overlayWindow.outputX
        y: overlayWindow.outputY
        width: overlayWindow.modelData.width
        height: overlayWindow.modelData.height
        outputName: overlayWindow.modelData.name
        outputOriginX: overlayWindow.modelData.x
        outputOriginY: overlayWindow.modelData.y
    }

    Item {
        id: keyHandler

        focus: overlayWindow.visible
        Keys.onEscapePressed: ScreenshotSession.dismiss()
        Keys.onReturnPressed: ScreenshotSession.capture()
        Keys.onEnterPressed: ScreenshotSession.capture()
    }

    ScreenshotOptions {
        visible: overlayWindow.hostsToolbar
        outputX: overlayWindow.outputX
        outputY: overlayWindow.outputY
        toolbarItem: toolbar
    }

    ScreenshotToolbar {
        id: toolbar

        visible: overlayWindow.hostsToolbar
        outputX: overlayWindow.outputX
        outputY: overlayWindow.outputY
        outputWidth: overlayWindow.modelData.width
        outputHeight: overlayWindow.modelData.height
    }
}
