import QtQuick
import Quickshell

Text {
    id: clockWidget

    property string format: "h:mmAP"

    text: Qt.formatDateTime(clock.date, clockWidget.format)

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
