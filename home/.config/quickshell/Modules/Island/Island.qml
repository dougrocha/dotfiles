pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Components
import qs.Constants
import qs.Services

Variants {
    id: root
    model: Desktop.primaryScreens

    delegate: PanelWindow {
        id: overlay

        required property var modelData
        screen: modelData

        color: "transparent"
        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: 560
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs.island"

        readonly property bool revealed: IslandService.revealed

        mask: Region {
            x: surface.pillItem.x
            y: slide.y + surface.pillItem.y
            width: overlay.revealed ? surface.pillItem.width : 0
            height: overlay.revealed ? surface.pillItem.height : 0

            Region {
                x: surface.bubbleItem.x
                y: slide.y + surface.bubbleItem.y
                width: surface.bubbleItem.visible ? surface.bubbleItem.width : 0
                height: surface.bubbleItem.visible ? surface.bubbleItem.height : 0
            }
        }

        PopupGrab {
            windows: [overlay]
            active: overlay.visible && Visibilities.isOpen(Visibilities.names.music)
            onDismissed: Visibilities.close(Visibilities.names.music)
        }

        Item {
            id: slide
            width: parent.width
            height: parent.height
            y: overlay.revealed ? 0 : -(surface.pillItem.y + surface.pillItem.height)

            SpringMotion on y {}

            IslandSurface {
                id: surface

                anchors.fill: parent
                revealed: overlay.revealed
            }
        }
    }
}
