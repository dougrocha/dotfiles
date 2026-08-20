import QtQuick
import qs.Constants

Rectangle {
    id: card

    required property bool shown
    property int padding: Theme.popup.margin
    default property alias content: col.data

    signal dismissed

    property real reveal: shown ? 1 : 0
    Behavior on reveal {
        NumberAnimation {
            duration: card.shown ? 160 : 120
            easing.type: card.shown ? Easing.OutCubic : Easing.InCubic
        }
    }

    height: col.implicitHeight + padding * 2
    radius: Theme.popup.radius
    color: Colors.surface_container
    opacity: reveal
    transform: Translate {
        y: (1 - card.reveal) * -6
    }

    focus: shown
    Keys.onPressed: function (event) {
        if (event.key === Qt.Key_Escape) {
            card.dismissed();
            event.accepted = true;
        }
    }

    Column {
        id: col
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: card.padding
        spacing: Theme.popup.spacing
    }
}
