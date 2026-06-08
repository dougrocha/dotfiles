import QtQuick

Text {
    id: clockWidget

    property string format: "h:mmAP"
    property int updateInterval: 1000

    text: Qt.formatDateTime(new Date(), format)

    Timer {
        interval: clockWidget.updateInterval
        running: true
        repeat: true
        onTriggered: clockWidget.text = Qt.formatDateTime(new Date(), clockWidget.format)
    }
}
