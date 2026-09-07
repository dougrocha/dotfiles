import QtQuick
import qs.Constants

Rectangle {
    id: root

    property string glyph: ""
    property int size: 24
    property int glyphSize: 14
    property bool circular: false
    property bool bordered: false
    property bool danger: false

    signal tapped

    readonly property color emphasis: root.danger ? Theme.danger : Theme.accent

    width: size
    height: size
    radius: circular ? width / 2 : Theme.radius.md
    color: hover.hovered ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)
    border.width: bordered ? 1 : 0
    border.color: hover.hovered ? root.emphasis : Theme.stroke.hairline

    Behavior on color {
        ColorAnimation {
            duration: Theme.motion.fast
        }
    }
    Behavior on border.color {
        ColorAnimation {
            duration: Theme.motion.fast
        }
    }

    Text {
        anchors.centerIn: parent
        text: root.glyph
        color: hover.hovered ? (root.danger ? Theme.danger : Theme.text.primary) : Theme.text.tertiary
        font.family: Theme.font.icon
        font.pixelSize: root.glyphSize

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
        onTapped: root.tapped()
    }
}
