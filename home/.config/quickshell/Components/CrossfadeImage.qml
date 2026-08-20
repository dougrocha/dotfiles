import QtQuick
import qs.Constants

Item {
    id: fadeRoot

    property string source: ""
    property int fillMode: Image.PreserveAspectCrop
    property int duration: Theme.animations.normal

    readonly property bool ready: art.status === Image.Ready

    onSourceChanged: {
        if (source === "") {
            fadeOut.stop();
            fadeIn.stop();
            art.source = "";
            art.opacity = 0;
            return;
        }
        if (art.source == "") {
            art.source = source;
            return;
        }
        fadeOut.restart();
    }

    Image {
        source: fadeRoot.source
        asynchronous: true
        visible: false
    }

    Image {
        id: art
        anchors.fill: parent
        fillMode: fadeRoot.fillMode
        asynchronous: true
        opacity: 0
        onStatusChanged: {
            if (status === Image.Ready && source == fadeRoot.source && !fadeOut.running)
                fadeIn.restart();
        }
    }

    NumberAnimation {
        id: fadeOut

        target: art
        property: "opacity"
        to: 0
        duration: fadeRoot.duration
        easing.type: Easing.InCubic
        onFinished: {
            art.source = fadeRoot.source;
            if (art.status === Image.Ready)
                fadeIn.restart();
        }
    }

    NumberAnimation {
        id: fadeIn

        target: art
        property: "opacity"
        to: 1
        duration: fadeRoot.duration
        easing.type: Easing.OutCubic
    }
}
