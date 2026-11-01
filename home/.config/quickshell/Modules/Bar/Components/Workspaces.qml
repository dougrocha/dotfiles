pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Constants
import qs.Services

Item {
    id: root

    required property var screen

    readonly property int activeWorkspaceId: Desktop.activeWorkspaceId(screen)
    readonly property string openSpecialName: Desktop.openSpecial(screen)

    readonly property list<int> workspaceIds: {
        const ids = [1, 2, 3, 4, 5];
        for (const workspace of Hyprland.workspaces.values) {
            if (workspace.id > 0 && workspace.id <= 10 && !ids.includes(workspace.id))
                ids.push(workspace.id);
        }
        return ids.sort((a, b) => a - b);
    }

    readonly property list<var> extraWorkspaces: Hyprland.workspaces.values.filter(workspace => isExtra(workspace) && (isCurrentExtra(workspace) || (!isSpecial(workspace) && isOccupied(workspace)))).sort((a, b) => labelFor(a).localeCompare(labelFor(b)))

    function isExtra(workspace) {
        return workspace.id < 0 || !/^\d+$/.test(workspace.name);
    }

    function isSpecial(workspace) {
        return workspace.name.startsWith("special:");
    }

    function isOccupied(workspace) {
        return (workspace?.toplevels?.values?.length ?? 0) > 0;
    }

    function isCurrentExtra(workspace) {
        return isSpecial(workspace) ? workspace.name === openSpecialName : activeWorkspaceId === workspace.id;
    }

    function labelFor(workspace) {
        return workspace.name.replace(/^(special|name):/, "");
    }

    function openExtra(workspace) {
        Visibilities.dismissAll();
        const name = labelFor(workspace);
        if (isSpecial(workspace))
            Desktop.toggleSpecial(name);
        else
            Desktop.focusNamedWorkspace(name);
    }

    function workspaceFor(id) {
        return Hyprland.workspaces.values.find(workspace => workspace.id === id) ?? null;
    }

    function focusWorkspace(id) {
        Visibilities.dismissAll();
        Desktop.focusWorkspace(id);
    }

    readonly property Item activeCell: {
        for (let i = 0; i < labelRepeater.count; ++i) {
            const cell = labelRepeater.itemAt(i);
            if (cell?.current)
                return cell;
        }
        for (let i = 0; i < numberRepeater.count; ++i) {
            const cell = numberRepeater.itemAt(i);
            if (cell?.current)
                return cell;
        }
        return null;
    }

    implicitWidth: row.implicitWidth
    implicitHeight: Theme.topBarHeight

    component WorkspaceNumber: Item {
        id: cell

        required property int modelData

        readonly property var workspace: root.workspaceFor(modelData)
        readonly property bool current: root.activeWorkspaceId === modelData
        readonly property bool occupied: root.isOccupied(workspace)

        implicitWidth: Theme.bar.plateHeight
        implicitHeight: Theme.topBarHeight

        BarPlate {
            hovered: hover.hovered && !cell.current
        }

        Text {
            anchors.centerIn: parent
            text: cell.modelData === 10 ? "0" : String(cell.modelData)
            color: cell.current || hover.hovered ? Theme.text.primary : cell.occupied ? Theme.text.primary : Theme.text.secondary
            font.family: Theme.font.mono
            font.pixelSize: Theme.type.mono.size
            font.weight: Theme.type.mono.weight

            Behavior on color {
                ColorAnimation {
                    duration: Theme.motion.fast
                }
            }
        }

        HoverHandler {
            id: hover
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: root.focusWorkspace(cell.modelData)
        }
    }

    component WorkspaceLabel: Item {
        id: label

        required property var modelData
        required property int index

        readonly property bool current: root.isCurrentExtra(modelData)

        implicitWidth: labelText.implicitWidth + Theme.bar.platePadding * 2
        implicitHeight: Theme.topBarHeight
        Layout.leftMargin: index === 0 ? Theme.space.xs : 0

        BarPlate {
            hovered: labelHover.hovered && !label.current
        }

        Text {
            id: labelText
            anchors.centerIn: parent
            text: root.labelFor(label.modelData)
            color: Theme.text.primary
            font.family: Theme.font.mono
            font.pixelSize: Theme.type.mono.size
            font.weight: Theme.type.mono.weight
            font.letterSpacing: Theme.type.mono.tracking

            Behavior on color {
                ColorAnimation {
                    duration: Theme.motion.fast
                }
            }
        }

        HoverHandler {
            id: labelHover
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: root.openExtra(label.modelData)
        }
    }

    Rectangle {
        id: indicator

        readonly property real targetStart: root.activeCell ? row.x + root.activeCell.x : 0
        readonly property real targetEnd: root.activeCell ? targetStart + root.activeCell.width : 0
        property real start: targetStart
        property real end: targetEnd

        visible: root.activeCell !== null
        x: start
        width: end - start
        height: Theme.bar.plateHeight
        anchors.verticalCenter: parent.verticalCenter
        radius: Theme.bar.plateRadius
        color: Theme.fill.strong

        Behavior on start {
            id: startMotion
            NumberAnimation {
                duration: startMotion.targetValue > indicator.start ? Theme.motion.slow : Theme.motion.normal
                easing.type: Theme.motion.easeStandard
            }
        }

        Behavior on end {
            id: endMotion
            NumberAnimation {
                duration: endMotion.targetValue < indicator.end ? Theme.motion.slow : Theme.motion.normal
                easing.type: Theme.motion.easeStandard
            }
        }
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 0

        Repeater {
            id: numberRepeater
            model: ScriptModel {
                values: root.workspaceIds
            }

            delegate: WorkspaceNumber {}
        }

        Repeater {
            id: labelRepeater
            model: ScriptModel {
                values: root.extraWorkspaces
                objectProp: "name"
            }

            delegate: WorkspaceLabel {}
        }
    }
}
