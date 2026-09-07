import QtQuick

Text {
    id: clockWidget

    property string format: "h:mmAP"
    property int updateInterval: 1000

    property var now: new Date()

    text: Qt.formatDateTime(clockWidget.now, clockWidget.format)

    Timer {
        interval: clockWidget.updateInterval
        running: true
        repeat: true
        onTriggered: clockWidget.now = new Date()
    }
}
