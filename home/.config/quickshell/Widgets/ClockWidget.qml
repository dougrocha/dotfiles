import QtQuick
import Quickshell

Text {
    id: clockWidget

    property string format: "h:mm AP"

    text: Qt.formatDateTime(clock.date, clockWidget.format)

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
