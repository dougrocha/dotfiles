import QtQuick
import QtQuick.Layouts
import qs.Constants

Rectangle {
    id: root

    property string label: ""
    property bool checked: false
    property int glyphSize: Theme.icon.md

    signal tapped

    Layout.fillWidth: true
    implicitHeight: 30
    radius: Theme.radius.sm
    color: checkHover.hovered ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

    Behavior on color {
        ColorAnimation {
            duration: Theme.motion.fast
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 6

        Text {
            Layout.preferredWidth: 16
            text: PhosphorIcons.check
            color: Theme.accent
            font.pixelSize: root.glyphSize
            font.family: Theme.font.icon
            opacity: root.checked ? 1 : 0
        }
        Text {
            Layout.fillWidth: true
            text: root.label
            color: Theme.text.primary
            font.pixelSize: Theme.type.body.size
            font.family: Theme.font.ui
            elide: Text.ElideMiddle
        }
    }

    HoverHandler {
        id: checkHover
        cursorShape: Qt.PointingHandCursor
    }
    TapHandler {
        onTapped: root.tapped()
    }
}
