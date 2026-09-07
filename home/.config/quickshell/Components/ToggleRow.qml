import QtQuick
import qs.Constants

Rectangle {
    id: root

    property string glyph: ""
    property string label: ""
    property bool active: false
    property string style: "solid"
    property bool danger: false
    property int boxWidth: 56
    property int boxHeight: 40

    signal toggled

    readonly property bool compact: style === "compact"
    readonly property bool check: style === "check"

    implicitWidth: compact ? boxWidth : 220
    implicitHeight: compact ? boxHeight : check ? 30 : 34
    radius: compact ? Theme.radius.lg : check ? Theme.radius.sm : Theme.radius.md

    color: {
        if (root.active && !root.check)
            return root.danger ? Theme.withAlpha(Theme.danger, 0.18) : Theme.fill.selectedSolid;
        if (root.check)
            return hover.hovered ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0);
        return hover.hovered ? Theme.colors.overlay : Theme.colors.raised;
    }

    Behavior on color {
        ColorAnimation {
            duration: Theme.motion.fast
        }
    }

    Item {
        anchors.fill: parent
        visible: !root.compact

        Text {
            id: lead
            anchors.left: parent.left
            anchors.leftMargin: root.check ? Theme.space.md : Theme.space.lg
            anchors.verticalCenter: parent.verticalCenter
            font.family: Theme.font.icon
            font.pixelSize: root.check ? 16 : 15
            text: root.check ? PhosphorIcons.check : root.glyph
            visible: root.check || root.glyph !== ""
            opacity: root.check ? (root.active ? 1 : 0) : 1
            color: root.check ? Theme.accent : root.active ? Theme.accentText : Theme.text.secondary

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.motion.fast
                }
            }
            Behavior on color {
                ColorAnimation {
                    duration: Theme.motion.fast
                }
            }
        }

        Text {
            anchors.left: lead.visible ? lead.right : parent.left
            anchors.leftMargin: lead.visible ? Theme.space.md : Theme.space.lg
            anchors.right: parent.right
            anchors.rightMargin: Theme.space.lg
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            elide: Text.ElideRight
            font.family: Theme.font.ui
            font.pixelSize: Theme.type.body.size
            color: (root.active && root.style === "solid") ? Theme.accentText : Theme.text.primary

            Behavior on color {
                ColorAnimation {
                    duration: Theme.motion.fast
                }
            }
        }
    }

    Text {
        anchors.centerIn: parent
        visible: root.compact
        text: root.glyph !== "" ? root.glyph : root.label
        font.family: root.glyph !== "" ? Theme.font.icon : Theme.font.ui
        font.pixelSize: root.glyph !== "" ? 18 : Theme.type.caption.size
        font.weight: root.glyph !== "" ? Font.Normal : Font.Medium
        color: root.active ? (root.danger ? Theme.danger : Theme.accentText) : Theme.text.primary

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
        onTapped: root.toggled()
    }
}
