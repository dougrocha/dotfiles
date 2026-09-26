import QtQuick
import qs.Constants

Item {
    id: root

    property string source: ""
    property int fillMode: Image.PreserveAspectCrop
    property int duration: Theme.motion.normal
    property var tag: null
    property var shownTag: null

    property bool firstOnTop: true
    property int generation: 0
    property Image outgoing: null

    readonly property Image front: firstOnTop ? layer1 : layer2
    readonly property Image back: firstOnTop ? layer2 : layer1

    readonly property bool ready: front.url !== "" && front.status === Image.Ready

    onSourceChanged: request()
    onTagChanged: Qt.callLater(syncTag)
    Component.onCompleted: {
        request();
        syncTag();
    }

    function syncTag() {
        if (source === front.url)
            shownTag = tag;
    }

    function request() {
        generation++;
        finishFade();
        if (source === front.url && front.status !== Image.Error) {
            back.url = "";
            back.generation = -1;
            return;
        }
        const candidate = back;
        candidate.opacity = 0;
        candidate.generation = generation;
        candidate.url = source;
        settle(candidate);
    }

    function settle(candidate) {
        if (candidate.generation !== generation || candidate !== back)
            return;
        if (candidate.url !== "" && candidate.status !== Image.Ready && candidate.status !== Image.Error)
            return;
        candidate.generation = -1;
        promote(candidate);
    }

    function promote(candidate) {
        const previous = front;
        const hasImage = candidate.url !== "" && candidate.status === Image.Ready;
        candidate.z = 1;
        previous.z = 0;
        firstOnTop = candidate === layer1;
        outgoing = previous;
        fade.target = hasImage ? candidate : previous;
        fade.to = hasImage ? 1 : 0;
        fade.restart();
        if (!root.visible)
            finishFade();
        syncTag();
    }

    function finishFade() {
        if (fade.running)
            fade.complete();
        releaseOutgoing();
    }

    function releaseOutgoing() {
        if (!outgoing)
            return;
        outgoing.url = "";
        outgoing.opacity = 0;
        outgoing = null;
    }

    Image {
        id: layer1

        property string url: ""
        property int generation: -1

        anchors.fill: parent
        source: url
        fillMode: root.fillMode
        asynchronous: true
        opacity: 0
        onStatusChanged: root.settle(layer1)
    }

    Image {
        id: layer2

        property string url: ""
        property int generation: -1

        anchors.fill: parent
        source: url
        fillMode: root.fillMode
        asynchronous: true
        opacity: 0
        onStatusChanged: root.settle(layer2)
    }

    NumberAnimation {
        id: fade

        property: "opacity"
        duration: root.duration
        easing.type: Theme.motion.easeStandard
        onFinished: root.releaseOutgoing()
    }
}
