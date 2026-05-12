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

    Process {
        id: switchAudioProcess

        command: ["launch-or-focus-tui", "wiremix"]
    }
}
