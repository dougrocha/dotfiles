pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Constants
import qs.Services

Item {
    id: root

    required property var monitor

    readonly property var activeWorkspace: monitor?.activeWorkspace
    readonly property string openSpecialName: monitor?.lastIpcObject?.specialWorkspace?.name ?? ""

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
        return isSpecial(workspace) ? workspace.name === openSpecialName : activeWorkspace?.id === workspace.id;
    }

    function labelFor(workspace) {
        return workspace.name.replace(/^(special|name):/, "");
    }

    function openExtra(workspace) {
        Visibilities.closeAll();
        const name = JSON.stringify(labelFor(workspace));
        if (isSpecial(workspace))
            Hyprland.dispatch(`hl.dsp.workspace.toggle_special(${name})`);
        else
            Hyprland.dispatch(`hl.dsp.focus({ workspace = ${JSON.stringify("name:" + labelFor(workspace))} })`);
    }

    function workspaceFor(id) {
        return Hyprland.workspaces.values.find(workspace => workspace.id === id) ?? null;
    }

    function focusWorkspace(id) {
        Visibilities.closeAll();
        Hyprland.dispatch(`hl.dsp.focus({ workspace = ${id} })`);
    }

    implicitWidth: row.implicitWidth
    implicitHeight: Theme.topBarHeight

    component WorkspaceNumber: Item {
        id: cell

        required property int modelData

        readonly property var workspace: root.workspaceFor(modelData)
        readonly property bool current: root.activeWorkspace?.id === modelData
        readonly property bool occupied: root.isOccupied(workspace)

        implicitWidth: 22
        implicitHeight: Theme.topBarHeight

        Text {
            anchors.centerIn: parent
            text: cell.current ? PhosphorIcons.circle : cell.modelData === 10 ? "0" : String(cell.modelData)
            color: cell.current || hover.hovered ? Theme.text.primary : cell.occupied ? Theme.text.secondary : Theme.text.tertiary
            font.family: cell.current ? Theme.font.iconFill : Theme.font.mono
            font.pixelSize: cell.current ? Theme.icon.xxs : Theme.type.mono.size
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

        implicitWidth: labelText.implicitWidth + Theme.space.sm * 2
        implicitHeight: Theme.topBarHeight
        Layout.leftMargin: index === 0 ? Theme.space.xs : 0

        Text {
            id: labelText
            anchors.centerIn: parent
            text: root.labelFor(label.modelData)
            color: label.current || labelHover.hovered ? Theme.text.primary : Theme.text.secondary
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
            id: labelHover
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: root.openExtra(label.modelData)
        }
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 0

        Repeater {
            model: ScriptModel {
                values: root.workspaceIds
            }

            delegate: WorkspaceNumber {}
        }

        Repeater {
            model: ScriptModel {
                values: root.extraWorkspaces
                objectProp: "name"
            }

            delegate: WorkspaceLabel {}
        }
    }
}
