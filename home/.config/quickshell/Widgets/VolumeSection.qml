import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.Services

RowLayout {
    id: root

    // Accept theme properties from parent
    property color textColor
    property color separatorColor
    property int fontSize
    property string fontFamily

    spacing: 0

    WrapperMouseArea {
        id: clickWrapper
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: {
            switchAudioProcess.running = true;
        }

        Text {
            text: {
                var volText = "Vol: " + Math.round(AudioService.volume * 100) + "%";
                if (AudioService.muted)
                    volText += " (Muted)";

                return volText;
            }
            color: root.textColor
            font.pixelSize: root.fontSize
            font.family: root.fontFamily
            font.bold: true
        }
    }

    Rectangle {
        Layout.preferredWidth: 1
        Layout.preferredHeight: 16
        Layout.alignment: Qt.AlignVCenter
        Layout.leftMargin: 8
        Layout.rightMargin: 8
        color: root.separatorColor
    }

    Process {
        id: switchAudioProcess

        command: ["launch-or-focus-tui", "wiremix"]
    }
}
