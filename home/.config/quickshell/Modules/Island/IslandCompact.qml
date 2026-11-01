import QtQuick
import qs.Constants
import qs.Services

Row {
    id: compact

    property bool shown: true
    property string activity: "idle"
    property bool revealed: true

    height: Theme.island.lineHeight
    spacing: Theme.space.md
    opacity: shown ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
        NumberAnimation {
            duration: Theme.motion.fast
        }
    }

    Item {
        anchors.verticalCenter: parent.verticalCenter
        visible: compact.activity !== "idle"
        width: compact.activity === "music" ? music.implicitWidth : compact.activity === "osd" ? osd.implicitWidth : compact.activity === "recording" ? recording.implicitWidth : compact.activity === "alert" ? alert.implicitWidth : 0
        height: parent.height

        CompactMusic {
            id: music

            anchors.verticalCenter: parent.verticalCenter
            shown: compact.activity === "music"
            revealed: compact.revealed
        }

        CompactOsd {
            id: osd

            anchors.verticalCenter: parent.verticalCenter
            shown: compact.activity === "osd"
        }

        CompactAlert {
            id: alert

            anchors.verticalCenter: parent.verticalCenter
            shown: compact.activity === "alert"
        }

        CompactRecording {
            id: recording

            anchors.verticalCenter: parent.verticalCenter
            shown: compact.activity === "recording"
        }
    }

    RecordingDot {
        visible: AudioService.micInUse
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.caution
    }
}
