import QtQuick
import qs.Constants

Item {
    id: root

    property string source: ""
    property int fillMode: Image.PreserveAspectCrop
    property int duration: Theme.motion.normal

    property bool secondOnTop: false
    readonly property Image shown: secondOnTop ? layer2 : layer1
    readonly property Image pending: secondOnTop ? layer1 : layer2

    readonly property bool ready: (layer1.status === Image.Ready && layer1.opacity > 0) || (layer2.status === Image.Ready && layer2.opacity > 0)

    onSourceChanged: {
        if (source === "") {
            fade.stop();
            layer1.source = "";
            layer2.source = "";
            layer1.opacity = 0;
            layer2.opacity = 0;
            return;
        }
        if (String(root.shown.source) === source)
            return;
        if (fade.running)
            fade.complete();
        root.pending.source = source;
        if (root.pending.status === Image.Ready)
            root.promote();
    }

    function promote() {
        fade.stop();
        const incoming = root.pending;
        incoming.opacity = 0;
        incoming.z = 1;
        root.shown.z = 0;
        root.secondOnTop = !root.secondOnTop;
        fade.target = incoming;
        fade.restart();
    }

    Image {
        id: layer1
        anchors.fill: parent
        fillMode: root.fillMode
        asynchronous: true
        opacity: 0
        onStatusChanged: if (status === Image.Ready && root.pending === layer1 && String(source) === root.source)
            root.promote()
    }

    Image {
        id: layer2
        anchors.fill: parent
        fillMode: root.fillMode
        asynchronous: true
        opacity: 0
        onStatusChanged: if (status === Image.Ready && root.pending === layer2 && String(source) === root.source)
            root.promote()
    }

    NumberAnimation {
        id: fade

        property: "opacity"
        to: 1
        duration: root.duration
        easing.type: Theme.motion.easeSmooth
        onFinished: root.pending.opacity = 0
    }
}
