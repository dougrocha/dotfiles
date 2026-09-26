import QtQuick
import qs.Constants
import qs.Services
import qs.Widgets

ClockWidget {
    id: clock

    readonly property var formats: ["h:mmAP", "ddd h:mmAP", "MMM d  h:mmAP"]
    readonly property bool active: Visibilities.notificationCenter

    function cycleFormat() {
        const next = (formats.indexOf(SettingsService.clockFormat) + 1) % formats.length;
        SettingsService.clockFormat = formats[next];
    }

    format: SettingsService.clockFormat
    color: clock.active || clockHover.hovered ? Theme.text.primary : Theme.text.secondary
    font.pixelSize: Theme.type.mono.size
    font.family: Theme.font.mono
    font.weight: Theme.type.mono.weight
    font.letterSpacing: Theme.type.mono.tracking

    Behavior on color {
        ColorAnimation {
            duration: Theme.motion.fast
        }
    }

    HoverHandler {
        id: clockHover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: Visibilities.toggleNotificationCenter()
    }

    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: clock.cycleFormat()
    }
}
