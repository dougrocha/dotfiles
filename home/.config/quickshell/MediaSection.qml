import "./Services"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

RowLayout {
    id: root

    // Accept theme properties from parent
    property color colYellow
    property color colMuted
    property int fontSize
    property string fontFamily
    readonly property var players: Players
    property var selectedPlayer: players.active

    spacing: 0

    Connections {
        function onActiveChanged() {
            if (players.active && (!selectedPlayer || selectedPlayer !== players.active))
                selectedPlayer = players.active;

        }

        target: players
    }

    Text {
        visible: players.active !== null
        text: {
            if (!players.active)
                return "None";

            var metadata = players.active.metadata;
            if (!metadata)
                return "None";

            var title = metadata["xesam:title"] || "No Title";
            var artist = metadata["xesam:artist"] || "";
            // Show "Artist - Title" or just "Title"
            if (artist && artist.length > 0)
                return artist + " - " + title;

            return title;
        }
        color: root.colYellow
        font.pixelSize: root.fontSize
        font.family: root.fontFamily
        font.bold: true
        Layout.rightMargin: 8
        elide: Text.ElideRight
        Layout.maximumWidth: 200
    }

    Rectangle {
        visible: players.active !== null
        Layout.preferredWidth: 1
        Layout.preferredHeight: 16
        Layout.alignment: Qt.AlignVCenter
        Layout.leftMargin: 0
        Layout.rightMargin: 8
        color: root.colMuted
    }

}
