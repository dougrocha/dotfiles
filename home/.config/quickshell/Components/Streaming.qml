import "../Services"
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: streamingComponent

    spacing: 0
    visible: StreamingService.isStreaming
    Layout.preferredWidth: StreamingService.isStreaming ? implicitWidth : 0

    Text {
        id: statusText

        text: "󰻂"
        color: "#f7768e"
        font.pixelSize: 14
        font.family: "JetBrainsMono Nerd Font Propo"
        font.bold: true
        Layout.rightMargin: 8
    }

}
