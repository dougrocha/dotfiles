import QtQuick
import qs.Constants

Item {
    id: row

    property bool danger: false
    readonly property bool hovered: hover.hovered
    readonly property bool highlighted: hovered || activeFocus

    signal tapped

    width: parent ? parent.width : implicitWidth
    implicitHeight: 34
    activeFocusOnTab: true

    Keys.onPressed: function (event) {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            row.tapped();
            event.accepted = true;
        }
    }

    Rectangle {
        x: -Theme.panel.rowBleed
        width: row.width + Theme.panel.rowBleed * 2
        height: row.height
        radius: Theme.radius.sm
        color: {
            if (!row.highlighted)
                return Theme.withAlpha(Theme.fill.hover, 0);
            return row.danger ? Theme.withAlpha(Theme.danger, 0.10) : Theme.fill.hover;
        }

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
        onTapped: row.tapped()
    }
}
