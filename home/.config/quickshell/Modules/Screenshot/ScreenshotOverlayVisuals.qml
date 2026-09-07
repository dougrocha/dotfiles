pragma ComponentBehavior: Bound

import QtQuick
import qs.Constants

Item {
    id: root

    required property var manager
    required property string monitorName
    required property real monitorX
    required property real monitorY

    function labelPosition(pointer, extent, direction, available): real {
        const gap = 14;
        const preferred = direction < 0 ? pointer - gap - extent : pointer + gap;
        return Math.max(8, Math.min(available - extent - 8, preferred));
    }

    function labelIsClamped(pointer, extent, direction, available): bool {
        const gap = 14;
        const preferred = direction < 0 ? pointer - gap - extent : pointer + gap;
        return preferred < 8 || preferred > available - extent - 8;
    }

    function centeredPosition(pointer, extent, available): real {
        return Math.max(8, Math.min(available - extent - 8, pointer - extent / 2));
    }

    function directedPosition(pointer, extent, direction, available): real {
        const clamped = labelIsClamped(pointer, extent, direction, available);
        return labelPosition(pointer, extent, clamped ? -direction : direction, available);
    }

    Rectangle {
        readonly property var targetWindow: root.manager.hoveredWindow ?? root.manager.selectedWindow
        visible: root.manager.selectedMode === "windows" && targetWindow != null
        x: targetWindow != null ? targetWindow.x - root.monitorX : 0
        y: targetWindow != null ? targetWindow.y - root.monitorY : 0
        width: targetWindow != null ? targetWindow.width : 0
        height: targetWindow != null ? targetWindow.height : 0
        radius: Theme.radius.md
        color: Theme.withAlpha(Theme.accent, 0.055)
        border.width: 1
        border.color: Theme.withAlpha(Theme.accent, 0.7)
    }

    Item {
        id: regionVisuals
        anchors.fill: parent
        visible: root.manager.selectedMode === "region"
        clip: true

        readonly property real sx: root.manager.selectionX - root.monitorX
        readonly property real sy: root.manager.selectionY - root.monitorY
        readonly property real sw: root.manager.selectionWidth
        readonly property real sh: root.manager.selectionHeight
        readonly property real intersectionLeft: Math.max(0, sx)
        readonly property real intersectionTop: Math.max(0, sy)
        readonly property real intersectionRight: Math.min(width, sx + sw)
        readonly property real intersectionBottom: Math.min(height, sy + sh)
        readonly property bool hasIntersection: root.manager.hasSelection && intersectionRight > intersectionLeft && intersectionBottom > intersectionTop

        Rectangle {
            anchors.fill: parent
            visible: !regionVisuals.hasIntersection
            color: "#66000000"
        }
        Rectangle {
            x: 0
            y: 0
            width: regionVisuals.width
            height: regionVisuals.intersectionTop
            visible: regionVisuals.hasIntersection
            color: "#66000000"
        }
        Rectangle {
            x: 0
            y: regionVisuals.intersectionTop
            width: regionVisuals.intersectionLeft
            height: regionVisuals.intersectionBottom - y
            visible: regionVisuals.hasIntersection
            color: "#66000000"
        }
        Rectangle {
            x: regionVisuals.intersectionRight
            y: regionVisuals.intersectionTop
            width: regionVisuals.width - x
            height: regionVisuals.intersectionBottom - y
            visible: regionVisuals.hasIntersection
            color: "#66000000"
        }
        Rectangle {
            x: 0
            y: regionVisuals.intersectionBottom
            width: regionVisuals.width
            height: regionVisuals.height - y
            visible: regionVisuals.hasIntersection
            color: "#66000000"
        }

        Rectangle {
            x: regionVisuals.sx
            y: regionVisuals.sy
            width: regionVisuals.sw
            height: regionVisuals.sh
            color: "transparent"
            border.width: root.manager.hasSelection && regionVisuals.sw > 0 ? 2 : 0
            border.color: Theme.accent
        }

        Repeater {
            model: root.manager.hasSelection ? [
                { x: regionVisuals.sx, y: regionVisuals.sy },
                { x: regionVisuals.sx + regionVisuals.sw / 2, y: regionVisuals.sy },
                { x: regionVisuals.sx + regionVisuals.sw, y: regionVisuals.sy },
                { x: regionVisuals.sx, y: regionVisuals.sy + regionVisuals.sh / 2 },
                { x: regionVisuals.sx + regionVisuals.sw, y: regionVisuals.sy + regionVisuals.sh / 2 },
                { x: regionVisuals.sx, y: regionVisuals.sy + regionVisuals.sh },
                { x: regionVisuals.sx + regionVisuals.sw / 2, y: regionVisuals.sy + regionVisuals.sh },
                { x: regionVisuals.sx + regionVisuals.sw, y: regionVisuals.sy + regionVisuals.sh }
            ] : []

            delegate: Rectangle {
                required property var modelData
                x: modelData.x - width / 2
                y: modelData.y - height / 2
                width: 8
                height: 8
                radius: Theme.radius.xs
                color: Theme.accent
                border.width: 1
                border.color: Theme.accentText
            }
        }

        Rectangle {
            id: sizeReadout
            readonly property real localPointerX: root.manager.pointerGlobalX - root.monitorX
            readonly property real localPointerY: root.manager.pointerGlobalY - root.monitorY
            readonly property string edgeAxis: root.manager.readoutEdgeAxis
            readonly property bool clampedOnBothAxes: root.labelIsClamped(localPointerX, width, root.manager.readoutDirectionX, regionVisuals.width) && root.labelIsClamped(localPointerY, height, root.manager.readoutDirectionY, regionVisuals.height)
            visible: root.manager.readoutVisible && root.manager.readoutMonitor === root.monitorName
            x: {
                if (edgeAxis === "vertical")
                    return root.centeredPosition(localPointerX, width, regionVisuals.width);
                if (edgeAxis === "horizontal")
                    return root.directedPosition(localPointerX, width, root.manager.readoutDirectionX, regionVisuals.width);
                return root.labelPosition(localPointerX, width, clampedOnBothAxes ? -root.manager.readoutDirectionX : root.manager.readoutDirectionX, regionVisuals.width);
            }
            y: {
                if (edgeAxis === "horizontal")
                    return root.centeredPosition(localPointerY, height, regionVisuals.height);
                if (edgeAxis === "vertical")
                    return root.directedPosition(localPointerY, height, root.manager.readoutDirectionY, regionVisuals.height);
                return root.labelPosition(localPointerY, height, clampedOnBothAxes ? -root.manager.readoutDirectionY : root.manager.readoutDirectionY, regionVisuals.height);
            }
            width: sizeText.implicitWidth + 16
            height: sizeText.implicitHeight + 10
            radius: Theme.radius.sm
            color: Theme.colors.raised
            border.width: 1
            border.color: Theme.stroke.hairline

            Text {
                id: sizeText
                anchors.centerIn: parent
                text: Math.round(root.manager.selectionWidth) + " × " + Math.round(root.manager.selectionHeight)
                color: Theme.text.primary
                font.pixelSize: Theme.type.body.size
                font.family: Theme.font.ui
            }
        }
    }
}
