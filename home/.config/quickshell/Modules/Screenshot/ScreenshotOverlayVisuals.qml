pragma ComponentBehavior: Bound

import QtQuick
import qs.Constants
import qs.Services

Item {
    id: root

    required property string outputName
    required property real outputOriginX
    required property real outputOriginY
    readonly property color selectionColor: Theme.accent
    readonly property color dimColor: Theme.withAlpha(Theme.shadow, 0.62)

    function preferredPosition(pointer, extent, direction): real {
        const gap = 14;
        return direction < 0 ? pointer - gap - extent : pointer + gap;
    }

    function labelPosition(pointer, extent, direction, available): real {
        return Math.max(8, Math.min(available - extent - 8, preferredPosition(pointer, extent, direction)));
    }

    function labelIsClamped(pointer, extent, direction, available): bool {
        const preferred = preferredPosition(pointer, extent, direction);
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
        readonly property var targetWindow: ScreenshotSession.highlightWindow
        visible: targetWindow != null
        x: targetWindow != null ? targetWindow.x - root.outputOriginX : 0
        y: targetWindow != null ? targetWindow.y - root.outputOriginY : 0
        width: targetWindow != null ? targetWindow.width : 0
        height: targetWindow != null ? targetWindow.height : 0
        radius: Theme.radius.md
        color: Theme.withAlpha(root.selectionColor, 0.08)
        border.width: 1
        border.color: root.selectionColor
    }

    Item {
        id: regionVisuals
        anchors.fill: parent
        visible: ScreenshotSession.visualMode === "region"
        clip: true

        readonly property var selection: ScreenshotSession.selection
        readonly property real sx: selection.x - root.outputOriginX
        readonly property real sy: selection.y - root.outputOriginY
        readonly property real sw: selection.width
        readonly property real sh: selection.height
        readonly property real intersectionLeft: Math.max(0, sx)
        readonly property real intersectionTop: Math.max(0, sy)
        readonly property real intersectionRight: Math.min(width, sx + sw)
        readonly property real intersectionBottom: Math.min(height, sy + sh)
        readonly property bool hasIntersection: ScreenshotSession.hasSelection && intersectionRight > intersectionLeft && intersectionBottom > intersectionTop

        Rectangle {
            anchors.fill: parent
            visible: !regionVisuals.hasIntersection
            color: root.dimColor
        }
        Rectangle {
            x: 0
            y: 0
            width: regionVisuals.width
            height: regionVisuals.intersectionTop
            visible: regionVisuals.hasIntersection
            color: root.dimColor
        }
        Rectangle {
            x: 0
            y: regionVisuals.intersectionTop
            width: regionVisuals.intersectionLeft
            height: regionVisuals.intersectionBottom - y
            visible: regionVisuals.hasIntersection
            color: root.dimColor
        }
        Rectangle {
            x: regionVisuals.intersectionRight
            y: regionVisuals.intersectionTop
            width: regionVisuals.width - x
            height: regionVisuals.intersectionBottom - y
            visible: regionVisuals.hasIntersection
            color: root.dimColor
        }
        Rectangle {
            x: 0
            y: regionVisuals.intersectionBottom
            width: regionVisuals.width
            height: regionVisuals.height - y
            visible: regionVisuals.hasIntersection
            color: root.dimColor
        }

        Rectangle {
            x: regionVisuals.sx - 1
            y: regionVisuals.sy - 1
            width: regionVisuals.sw + 2
            height: regionVisuals.sh + 2
            visible: ScreenshotSession.hasSelection
            color: "transparent"
            border.width: 1
            border.color: Theme.withAlpha(Theme.foregroundFor(root.selectionColor), 0.8)
        }

        Rectangle {
            x: regionVisuals.sx
            y: regionVisuals.sy
            width: regionVisuals.sw
            height: regionVisuals.sh
            color: "transparent"
            border.width: ScreenshotSession.hasSelection && regionVisuals.sw > 0 ? 2 : 0
            border.color: root.selectionColor
        }

        Repeater {
            model: ScreenshotSession.hasSelection ? 8 : 0

            delegate: Rectangle {
                required property int index
                readonly property real fx: [0, 0.5, 1, 0, 1, 0, 0.5, 1][index]
                readonly property real fy: [0, 0, 0, 0.5, 0.5, 1, 1, 1][index]
                x: regionVisuals.sx + regionVisuals.sw * fx - width / 2
                y: regionVisuals.sy + regionVisuals.sh * fy - height / 2
                width: 8
                height: 8
                radius: Theme.radius.xs
                color: root.selectionColor
                border.width: 1
                border.color: Theme.foregroundFor(root.selectionColor)
            }
        }

        Rectangle {
            id: sizeReadout
            readonly property var readout: ScreenshotSession.readout
            readonly property real localPointerX: readout.x - root.outputOriginX
            readonly property real localPointerY: readout.y - root.outputOriginY
            readonly property string edgeAxis: readout.edgeAxis
            readonly property bool clampedOnBothAxes: root.labelIsClamped(localPointerX, width, readout.directionX, regionVisuals.width) && root.labelIsClamped(localPointerY, height, readout.directionY, regionVisuals.height)
            visible: readout.visible && readout.screen === root.outputName
            x: {
                if (edgeAxis === "vertical")
                    return root.centeredPosition(localPointerX, width, regionVisuals.width);
                if (edgeAxis === "horizontal")
                    return root.directedPosition(localPointerX, width, readout.directionX, regionVisuals.width);
                return root.labelPosition(localPointerX, width, clampedOnBothAxes ? -readout.directionX : readout.directionX, regionVisuals.width);
            }
            y: {
                if (edgeAxis === "horizontal")
                    return root.centeredPosition(localPointerY, height, regionVisuals.height);
                if (edgeAxis === "vertical")
                    return root.directedPosition(localPointerY, height, readout.directionY, regionVisuals.height);
                return root.labelPosition(localPointerY, height, clampedOnBothAxes ? -readout.directionY : readout.directionY, regionVisuals.height);
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
                text: Math.round(regionVisuals.sw) + " × " + Math.round(regionVisuals.sh)
                color: Theme.text.primary
                font.pixelSize: Theme.type.body.size
                font.family: Theme.font.ui
            }
        }
    }
}
