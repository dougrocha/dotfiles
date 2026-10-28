import QtQuick
import QtQuick.Layouts
import qs.Constants

Item {
    id: root

    required property var entry
    property int indentLevel: 0
    property bool expanded: false
    readonly property bool valid: entry !== null && entry !== undefined
    readonly property bool separator: entry?.isSeparator ?? false
    readonly property bool interactive: valid && !separator && entry.enabled

    signal toggleRequested
    signal triggerRequested

    function activate() {
        if (entry.hasChildren)
            toggleRequested();
        else
            triggerRequested();
    }

    implicitHeight: !valid ? 0 : separator ? 9 : 28
    activeFocusOnTab: interactive

    Rectangle {
        visible: root.separator
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 1
        color: Theme.text.secondary
    }

    Rectangle {
        visible: root.valid && !root.separator
        anchors.fill: parent
        radius: Theme.radius.sm
        color: root.interactive && (rowHover.hovered || root.activeFocus) ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)
        border.width: root.activeFocus ? 1 : 0
        border.color: Theme.stroke.accent

        RowLayout {
            anchors {
                fill: parent
                leftMargin: 8 + root.indentLevel * 12
                rightMargin: 8
            }
            spacing: Theme.space.sm

            Text {
                visible: root.entry?.checkState === Qt.Checked
                text: PhosphorIcons.check
                color: Theme.accent
                font.pixelSize: Theme.type.body.size
                font.family: Theme.font.icon
            }

            Text {
                Layout.fillWidth: true
                text: root.entry?.text ?? ""
                color: root.interactive ? Theme.text.primary : Theme.text.secondary
                font.pixelSize: Theme.type.body.size
                font.family: Theme.font.ui
                elide: Text.ElideRight
            }

            Text {
                visible: root.entry?.hasChildren ?? false
                text: PhosphorIcons.caretRight
                color: root.expanded ? Theme.text.primary : Theme.text.secondary
                font.pixelSize: Theme.type.body.size
                font.family: Theme.font.icon

                transform: Rotation {
                    origin.x: 4
                    origin.y: 8
                    angle: root.expanded ? 90 : 0

                    Behavior on angle {
                        NumberAnimation {
                            duration: Theme.motion.fast
                            easing.type: Theme.motion.easeStandard
                        }
                    }
                }
            }
        }

        HoverHandler {
            id: rowHover
            enabled: root.interactive
            cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
        }
        TapHandler {
            enabled: root.interactive
            onTapped: root.activate()
        }
    }

    Keys.onPressed: event => {
        if (!root.valid)
            return;

        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            root.activate();
            event.accepted = true;
        }
    }
}
