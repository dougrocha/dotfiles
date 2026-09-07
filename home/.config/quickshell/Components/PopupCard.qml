import QtQuick
import qs.Constants

Rectangle {
    id: card

    required property bool shown
    property int padding: Theme.space.lg
    default property alias content: col.data

    signal dismissed

    property real reveal: shown ? 1 : 0
    Behavior on reveal {
        NumberAnimation {
            duration: card.shown ? Theme.motion.normal : Theme.motion.fast
            easing.type: card.shown ? Theme.motion.easeStandard : Theme.motion.easeExit
        }
    }

    height: col.implicitHeight + padding * 2
    radius: Theme.radius.xl
    color: Theme.colors.surface
    opacity: reveal
    clip: true
    transform: Translate {
        y: (1 - card.reveal) * -6
    }

    Behavior on height {
        NumberAnimation {
            duration: Theme.motion.normal
            easing.type: Theme.motion.easeStandard
        }
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
        spacing: Theme.space.md
    }
}
