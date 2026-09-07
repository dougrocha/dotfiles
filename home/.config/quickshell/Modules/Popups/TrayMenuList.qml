pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.Constants

Item {
    id: root

    property var menuHandle: null
    property int indentLevel: 0

    signal closeRequested

    implicitHeight: rootLoader.item ? rootLoader.item.implicitHeight : 0

    Component {
        id: menuBranchComponent

        Item {
            id: branch

            property var menuHandle: null
            property int indentLevel: 0

            signal closeRequested

            implicitHeight: branchColumn.implicitHeight

            QsMenuOpener {
                id: menuOpener
                menu: branch.menuHandle
            }

            Column {
                id: branchColumn
                width: parent.width
                spacing: Theme.space.xxs

                Repeater {
                    model: menuOpener.children.values

                    delegate: Column {
                        id: entryColumn

                        required property var modelData
                        property bool expanded: false
                        property bool submenuLoaded: false

                        width: branchColumn.width
                        spacing: Theme.space.xxs

                        onExpandedChanged: {
                            if (expanded)
                                submenuLoaded = true;
                        }

                        TrayMenuEntry {
                            width: parent.width
                            entry: entryColumn.modelData
                            indentLevel: branch.indentLevel
                            expanded: entryColumn.expanded
                            onToggleRequested: entryColumn.expanded = !entryColumn.expanded
                            onTriggerRequested: {
                                entryColumn.modelData.triggered();

                                branch.closeRequested();
                            }
                        }

                        Loader {
                            active: entryColumn.submenuLoaded && entryColumn.modelData !== null
                            width: parent.width
                            clip: true
                            height: entryColumn.expanded && item ? item.implicitHeight : 0
                            sourceComponent: menuBranchComponent

                            Behavior on height {
                                NumberAnimation {
                                    duration: Theme.motion.fast
                                    easing.type: Theme.motion.easeStandard
                                }
                            }

                            onLoaded: {
                                if (!entryColumn.modelData)
                                    return;

                                item.menuHandle = entryColumn.modelData;
                                item.indentLevel = branch.indentLevel + 1;
                                item.closeRequested.connect(branch.closeRequested);
                            }
                        }
                    }
                }
            }
        }
    }

    Loader {
        id: rootLoader
        anchors.fill: parent
        active: root.menuHandle !== null
        sourceComponent: menuBranchComponent

        onLoaded: {
            item.menuHandle = root.menuHandle;
            item.indentLevel = root.indentLevel;
            item.closeRequested.connect(root.closeRequested);
        }
    }

    onMenuHandleChanged: {
        if (rootLoader.item)
            rootLoader.item.menuHandle = menuHandle;
    }
}
