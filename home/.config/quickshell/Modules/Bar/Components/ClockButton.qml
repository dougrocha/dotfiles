import QtQuick
import QtQuick.Layouts
import qs.Constants
import qs.Services
import qs.Widgets

ClockWidget {
    id: clock

    readonly property var formats: ["h:mm AP", "ddd h:mm AP", "ddd MMM d  h:mm AP"]
    readonly property string currentFormat: SettingsService.clockFormat.replace("mmAP", "mm AP")
    readonly property bool active: Visibilities.isOpen(Visibilities.names.notifications)

    function cycleFormat() {
        const next = (formats.indexOf(currentFormat) + 1) % formats.length;
        SettingsService.clockFormat = formats[next];
    }

    format: currentFormat
    Layout.preferredHeight: Theme.topBarHeight
    leftPadding: Theme.bar.platePadding + Theme.space.xxs
    rightPadding: Theme.bar.platePadding + Theme.space.xxs
    verticalAlignment: Text.AlignVCenter
    color: Theme.text.primary
    font.pixelSize: Theme.type.mono.size
    font.family: Theme.font.mono
    font.weight: Theme.type.mono.weight
    font.letterSpacing: Theme.type.mono.tracking
    scale: clockTap.pressed ? Theme.motion.pressScale : 1

    Behavior on scale {
        NumberAnimation {
            duration: Theme.motion.instant
            easing.type: Theme.motion.easeStandard
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: Theme.motion.fast
        }
    }

    Rectangle {
        z: -1
        anchors.centerIn: parent
        width: parent.width
        height: Theme.bar.plateHeight
        radius: Theme.bar.plateRadius
        color: clock.active || clockTap.pressed ? Theme.fill.press : clockHover.hovered ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

        Behavior on color {
            ColorAnimation {
                duration: Theme.motion.fast
            }
        }
    }

    HoverHandler {
        id: clockHover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        id: clockTap
        onTapped: Visibilities.toggle(Visibilities.names.notifications)
    }

    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: clock.cycleFormat()
    }
}
