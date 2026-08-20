import QtQuick
import QtQuick.Controls
import qs.Constants

Slider {
    id: slider

    // The value to show when not being dragged. Bound via the suspended Binding
    // below so a drag (which writes `value`) doesn't tear the binding down.
    property real boundValue: 0

    // Extends that hold past the drag, for a bar whose source keeps pushing values mid-seek.
    property bool holding: false

    property color trackColor: Colors.outline_variant
    property color accentColor: Colors.primary
    property color pressedColor: Colors.primary_fixed
    property int handleSize: 12

    Binding {
        target: slider
        property: "value"
        value: slider.boundValue
        when: !slider.pressed && !slider.holding
        restoreMode: Binding.RestoreNone
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }

    background: Rectangle {
        x: slider.leftPadding
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        width: slider.availableWidth
        height: 3
        radius: 2
        color: slider.trackColor

        Rectangle {
            width: slider.visualPosition * parent.width
            height: parent.height
            color: slider.accentColor
            radius: 2

            Behavior on width {
                NumberAnimation {
                    duration: 80
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    handle: Rectangle {
        x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        implicitWidth: slider.handleSize
        implicitHeight: slider.handleSize
        radius: width / 2
        color: slider.pressed ? slider.pressedColor : slider.accentColor
    }
}
