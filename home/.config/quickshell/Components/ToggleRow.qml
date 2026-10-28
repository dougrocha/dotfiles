import QtQuick
import qs.Constants

Rectangle {
    id: root

    property string glyph: ""
    property string label: ""
    property bool active: false
    property string style: "switch"
    property int bleed: 0

    signal toggled

    implicitWidth: 220
    implicitHeight: 34
    radius: Theme.radius.sm
    color: "transparent"

    Rectangle {
        z: -1
        anchors.fill: parent
        anchors.leftMargin: -root.bleed
        anchors.rightMargin: -root.bleed
        radius: root.radius
        color: hover.hovered ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

        Behavior on color {
            ColorAnimation {
                duration: Theme.motion.fast
            }
        }
    }

    Text {
        id: lead

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        font.family: Theme.font.icon
        font.pixelSize: Theme.icon.sm
        text: root.glyph
        visible: root.glyph !== ""
        color: Theme.text.secondary
    }

    Text {
        anchors.left: lead.visible ? lead.right : parent.left
        anchors.leftMargin: 10
        anchors.right: knob.left
        anchors.rightMargin: Theme.space.lg
        anchors.verticalCenter: parent.verticalCenter
        text: root.label
        elide: Text.ElideRight
        font.family: Theme.font.ui
        font.pixelSize: Theme.type.body.size
        color: Theme.text.primary
    }

    Rectangle {
        id: knob

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 28
        height: 16
        radius: height / 2
        color: root.active ? Theme.accent : Theme.stroke.strong

        Behavior on color {
            ColorAnimation {
                duration: Theme.motion.fast
            }
        }

        Rectangle {
            y: 2
            x: root.active ? parent.width - width - 2 : 2
            width: 12
            height: 12
            radius: width / 2
            color: root.active ? Theme.accentText : Theme.text.secondary

            Behavior on x {
                NumberAnimation {
                    duration: Theme.motion.fast
                    easing.type: Theme.motion.easeStandard
                }
            }
            Behavior on color {
                ColorAnimation {
                    duration: Theme.motion.fast
                }
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
