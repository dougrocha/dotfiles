import QtQuick
import QtQuick.Controls
import qs.Constants

Slider {
    id: slider

    property real boundValue: 0
    property bool muted: false
    property string glyph: ""

    implicitHeight: 22
    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0
    from: 0
    to: 1

    Binding {
        target: slider
        property: "value"
        value: slider.boundValue
        when: !slider.pressed
        restoreMode: Binding.RestoreNone
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }

    background: Rectangle {
        width: slider.availableWidth
        height: slider.availableHeight
        radius: height / 2
        color: Theme.fill.press

        Rectangle {
            width: parent.height + slider.visualPosition * (parent.width - parent.height)
            height: parent.height
            radius: parent.radius
            color: slider.muted ? Theme.text.tertiary : Theme.text.primary

            Behavior on color {
                ColorAnimation {
                    duration: Theme.motion.fast
                }
            }
        }
    }

    handle: Rectangle {
        x: slider.visualPosition * (slider.availableWidth - width)
        width: slider.availableHeight
        height: slider.availableHeight
        radius: height / 2
        color: Theme.text.primary
        border.width: 1
        border.color: Theme.withAlpha(Theme.shadow, 0.18)
    }

    Text {
        z: 1
        x: (slider.availableHeight - width) / 2
        anchors.verticalCenter: parent.verticalCenter
        text: slider.glyph
        color: Theme.colors.surface
        font.family: Theme.font.iconFill
        font.pixelSize: Theme.icon.xxs
    }
}
