import QtQuick
import QtQuick.Controls
import qs.Constants

Slider {
    id: slider

    property real boundValue: 0

    property bool holding: false

    property color trackColor: Theme.stroke.strong
    property int handleSize: 12

    leftPadding: 0
    rightPadding: 0

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
        height: Theme.control.track
        radius: height / 2
        color: slider.trackColor

        Rectangle {
            width: slider.visualPosition * parent.width
            height: parent.height
            color: Theme.text.primary
            radius: height / 2

            Behavior on width {
                NumberAnimation {
                    duration: Theme.motion.instant
                    easing.type: Theme.motion.easeStandard
                }
            }
        }
    }

    handle: Rectangle {
        x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        implicitWidth: slider.handleSize * 1.5
        implicitHeight: slider.handleSize
        radius: height / 2
        visible: slider.handleSize > 0
        color: Theme.text.primary
    }
}
