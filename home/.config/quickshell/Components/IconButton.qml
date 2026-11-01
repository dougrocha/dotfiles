import QtQuick
import qs.Constants

Rectangle {
    id: root

    property string glyph: ""
    property int glyphSize: Theme.type.title.size
    property int box: 0
    property bool filled: false
    property bool plate: false
    property bool open: false
    property bool solid: false
    property bool hoverFill: false

    property bool active: false
    property color restColor: plate ? Theme.text.primary : Theme.text.secondary
    property color hoverColor: Theme.text.primary
    property color activeColor: Theme.accent

    property string tooltipText: ""

    signal tapped

    readonly property int side: filled ? 40 : box
    readonly property int plateWidth: Math.max(Theme.bar.plateHeight, glyphLabel.implicitWidth + Theme.bar.platePadding * 2)

    implicitWidth: side > 0 ? side : plate ? plateWidth : glyphLabel.implicitWidth
    implicitHeight: side > 0 ? side : Theme.topBarHeight
    radius: filled || hoverFill ? width / 2 : 0
    color: filled || (hoverFill && tap.pressed) ? Theme.fill.press : hoverFill && hover.hovered ? Theme.fill.hover : Theme.withAlpha(Theme.fill.press, 0)
    scale: (plate || hoverFill) && tap.pressed ? Theme.motion.pressScale : 1

    Behavior on color {
        ColorAnimation {
            duration: Theme.motion.fast
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: Theme.motion.instant
            easing.type: Theme.motion.easeStandard
        }
    }

    Rectangle {
        visible: root.plate
        anchors.centerIn: parent
        width: root.plateWidth
        height: Theme.bar.plateHeight
        radius: Theme.bar.plateRadius
        color: root.open || tap.pressed ? Theme.fill.press : hover.hovered ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

        Behavior on color {
            ColorAnimation {
                duration: Theme.motion.fast
            }
        }
    }

    Text {
        id: glyphLabel
        anchors.centerIn: parent
        text: root.glyph
        color: root.active ? root.activeColor : hover.hovered ? root.hoverColor : root.restColor
        font.pixelSize: root.glyphSize
        font.family: root.active || root.solid ? Theme.font.iconFill : Theme.font.icon

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
        id: tap
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
