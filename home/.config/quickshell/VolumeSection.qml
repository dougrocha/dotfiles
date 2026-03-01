import "./Services"
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    // Accept theme properties from parent
    property color textColor
    property color separatorColor
    property int fontSize
    property string fontFamily

    spacing: 0

    Text {
        text: {
            var volText = "Vol: " + Math.round(AudioService.sinkVolume) + "%";
            if (AudioService.sinkMuted)
                volText += " (Muted)";

            return volText;
        }
        color: root.textColor
        font.pixelSize: root.fontSize
        font.family: root.fontFamily
        font.bold: true
        Layout.rightMargin: 8
    }

    Rectangle {
        Layout.preferredWidth: 1
        Layout.preferredHeight: 16
        Layout.alignment: Qt.AlignVCenter
        Layout.leftMargin: 0
        Layout.rightMargin: 8
        color: root.separatorColor
    }

}
