import QtQuick
import qs.Constants

Rectangle {
    id: root

    property string glyph: ""
    property int glyphSize: Theme.type.title.size
    property int box: 0
    property bool filled: false

    property bool active: false
    property color restColor: Theme.text.secondary
    property color hoverColor: Theme.text.primary
    property color activeColor: Theme.accent

    property string tooltipText: ""

    signal tapped

    readonly property int side: filled ? 40 : box

    implicitWidth: side > 0 ? side : glyphLabel.implicitWidth
    implicitHeight: side > 0 ? side : Theme.topBarHeight
    radius: filled ? width / 2 : 0
    color: filled ? Theme.fill.press : Theme.withAlpha(Theme.fill.press, 0)

    Text {
        id: glyphLabel
        anchors.centerIn: parent
        text: root.glyph
        color: root.active ? root.activeColor : hover.hovered ? root.hoverColor : root.restColor
        font.pixelSize: root.glyphSize
        font.family: Theme.font.icon

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

    Loader {
        active: root.tooltipText !== ""
        sourceComponent: Tooltip {
            targetItem: root
            text: root.tooltipText
            hovered: hover.hovered
        }
    }
}
