import QtQuick
import QtQuick.Layouts
import qs.Constants

Item {
    id: root

    required property var entry
    property int indentLevel: 0
    property bool expanded: false
    readonly property bool valid: entry !== null && entry !== undefined

    signal toggleRequested
    signal triggerRequested

    implicitHeight: !valid ? 0 : entry.isSeparator ? 9 : 28
    activeFocusOnTab: valid && !entry.isSeparator && entry.enabled

    Rectangle {
        visible: root.valid && root.entry.isSeparator
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 1
        color: Colors.on_surface_variant
    }

    Rectangle {
        visible: root.valid && !root.entry.isSeparator
        anchors.fill: parent
        radius: 4
        color: root.valid && (rowMouseArea.containsMouse || root.activeFocus) && root.entry.enabled ? Colors.surface_container : "transparent"
        border.width: root.activeFocus ? 1 : 0
        border.color: Colors.outline

        RowLayout {
            anchors {
                fill: parent
                leftMargin: 8 + root.indentLevel * 12
                rightMargin: 8
            }
            spacing: 6

            Text {
                visible: root.valid && root.entry.checkState === Qt.Checked
                text: Icons.check
                color: Colors.primary
                font.pixelSize: Fonts.p
                font.family: Fonts.iconFont
            }

            Text {
                Layout.fillWidth: true
                text: root.valid ? root.entry.text : ""
                color: root.valid && root.entry.enabled ? Colors.on_surface : Colors.on_surface_variant
                font.pixelSize: Fonts.p
                font.family: Fonts.font
                elide: Text.ElideRight
            }

            Text {
                visible: root.valid && root.entry.hasChildren
                text: Icons.chevronRight
                color: root.expanded ? Colors.on_surface : Colors.on_surface_variant
                font.pixelSize: Fonts.p
                font.family: Fonts.iconFont

                transform: Rotation {
                    origin.x: 4
                    origin.y: 8
                    angle: root.expanded ? 90 : 0

                    Behavior on angle {
                        NumberAnimation {
                            duration: Theme.animations.fast
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }

        MouseArea {
            id: rowMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: root.valid && root.entry.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            enabled: root.valid && root.entry.enabled && !root.entry.isSeparator
            onClicked: root.entry.hasChildren ? root.toggleRequested() : root.triggerRequested()
        }
    }

    Keys.onPressed: event => {
        if (!root.valid)
            return;

        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            root.entry.hasChildren ? root.toggleRequested() : root.triggerRequested();
            event.accepted = true;
        }
    }
}
