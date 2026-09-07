pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Polkit
import Quickshell.Wayland
import qs.Constants

Item {
    id: root

    property string message: ""
    property string prompt: ""
    property bool responseRequired: false
    property bool responseVisible: false
    property bool submitted: false
    property bool errorFlash: false
    property bool closing: false
    property int shakeOffset: 0
    property bool revealPassword: false

    readonly property bool dialogVisible: agent.isActive || closing

    function syncFromFlow() {
        const flow = agent.flow;
        if (!flow)
            return;

        message = String(flow.message || "Authentication is needed");
        prompt = String(flow.inputPrompt || "").replace(/:\s*$/, "");
        responseRequired = !!flow.isResponseRequired;
        responseVisible = !!flow.responseVisible;

        if (responseRequired)
            submitted = false;
    }

    function beginFlow() {
        closeTimer.stop();
        closing = false;
        submitted = false;
        errorFlash = false;
        passwordInput.text = "";
        syncFromFlow();
        Qt.callLater(() => passwordInput.forceActiveFocus());
    }

    function resetSnapshot() {
        message = "";
        prompt = "";
        responseRequired = false;
        responseVisible = false;
        submitted = false;
        errorFlash = false;
        revealPassword = false;
        passwordInput.text = "";
    }

    function submitResponse() {
        const flow = agent.flow;
        if (!flow || !flow.isResponseRequired)
            return;
        submitted = true;
        errorFlash = false;
        flow.submit(passwordInput.text);
        passwordInput.text = "";
    }

    function cancelRequest() {
        const flow = agent.flow;
        passwordInput.text = "";
        submitted = false;
        closing = true;
        closeTimer.restart();
        if (flow)
            flow.cancelAuthenticationRequest();
    }

    function triggerFailureFeedback() {
        submitted = false;
        errorFlash = true;
        passwordInput.text = "";
        errorTimer.restart();
        shakeAnimation.restart();
        Qt.callLater(() => passwordInput.forceActiveFocus());
    }

    Timer {
        id: closeTimer
        interval: 300
        onTriggered: {
            root.closing = false;
            root.resetSnapshot();
        }
    }

    Timer {
        id: errorTimer
        interval: 1200
        onTriggered: root.errorFlash = false
    }

    SequentialAnimation {
        id: shakeAnimation
        NumberAnimation {
            target: root
            property: "shakeOffset"
            to: -8
            duration: 35
            easing.type: Theme.motion.easeSoft
        }
        NumberAnimation {
            target: root
            property: "shakeOffset"
            to: 8
            duration: 50
            easing.type: Theme.motion.easeSmooth
        }
        NumberAnimation {
            target: root
            property: "shakeOffset"
            to: 0
            duration: 55
            easing.type: Theme.motion.easeSoft
        }
    }

    PolkitAgent {
        id: agent
        path: "/qs/PolkitAgent"

        onAuthenticationRequestStarted: root.beginFlow()
        onIsActiveChanged: {
            if (isActive)
                root.syncFromFlow();
            else if (!root.closing)
                root.resetSnapshot();
        }
        onIsRegisteredChanged: {
            if (isRegistered)
                console.log("quickshell polkit agent registered");
            else
                console.warn("quickshell polkit agent is not registered; another agent may be running");
        }
    }

    Connections {
        target: agent.flow

        function onIsResponseRequiredChanged() {
            root.syncFromFlow();
            if (!agent.flow || !agent.flow.isResponseRequired)
                passwordInput.text = "";
            Qt.callLater(() => passwordInput.forceActiveFocus());
        }

        function onInputPromptChanged() {
            root.syncFromFlow();
        }
        function onResponseVisibleChanged() {
            root.syncFromFlow();
        }

        function onAuthenticationFailed() {
            root.syncFromFlow();
            root.triggerFailureFeedback();
        }

        function onAuthenticationSucceeded() {
            root.closing = true;
            closeTimer.restart();
        }

        function onAuthenticationRequestCancelled() {
            root.closing = true;
            closeTimer.restart();
        }
    }

    PanelWindow {
        id: panel
        visible: root.dialogVisible
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        color: "transparent"
        WlrLayershell.namespace: "qs.polkit"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        exclusionMode: ExclusionMode.Ignore

        Rectangle {
            anchors.fill: parent
            color: Theme.withAlpha(Theme.shadow, 0.5)
        }

        MouseArea {
            anchors.fill: parent
            onClicked: passwordInput.forceActiveFocus()
        }

        Rectangle {
            id: card
            width: 320
            height: 148
            radius: Theme.radius.xl
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: root.shakeOffset
            color: Theme.colors.surface
            border.width: 1
            border.color: root.errorFlash ? Theme.danger : Theme.stroke.hairline

            Behavior on border.color {
                ColorAnimation {
                    duration: Theme.motion.fast
                }
            }

            Item {
                id: keyCatcher
                anchors.fill: parent
                focus: true

                Keys.priority: Keys.BeforeItem
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        root.cancelRequest();
                        event.accepted = true;
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: Theme.space.md

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.space.md

                    Text {
                        text: PhosphorIcons.lock
                        font.family: Theme.font.icon
                        font.pixelSize: Theme.icon.lg
                        color: root.errorFlash ? Theme.danger : Theme.accent
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.message
                        color: Theme.text.primary
                        font.family: Theme.font.ui
                        font.pixelSize: Theme.type.body.size
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    radius: Theme.radius.md
                    color: Theme.colors.bg
                    border.width: 1
                    border.color: passwordInput.activeFocus ? Theme.accent : Theme.stroke.hairline

                    Behavior on border.color {
                        ColorAnimation {
                            duration: Theme.motion.fast
                        }
                    }

                    TextInput {
                        id: passwordInput
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 34
                        verticalAlignment: TextInput.AlignVCenter
                        clip: true
                        echoMode: (root.responseVisible || root.revealPassword) ? TextInput.Normal : TextInput.Password
                        passwordCharacter: "•"
                        color: root.errorFlash ? Theme.danger : Theme.text.primary
                        font.family: Theme.font.ui
                        font.pixelSize: Theme.type.body.size
                        readOnly: root.submitted || root.errorFlash
                        enabled: root.dialogVisible
                        onAccepted: root.submitResponse()
                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Escape) {
                                root.cancelRequest();
                                event.accepted = true;
                            }
                        }
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.errorFlash ? "Wrong password" : (root.submitted ? "Checking..." : (root.prompt || "Enter password"))
                        color: root.errorFlash ? Theme.danger : Theme.text.secondary
                        opacity: root.errorFlash ? 1 : 0.6
                        font.family: Theme.font.ui
                        font.pixelSize: Theme.type.body.size
                        visible: passwordInput.text.length === 0
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.revealPassword ? PhosphorIcons.eyeSlash : PhosphorIcons.eye
                        font.family: Theme.font.icon
                        font.pixelSize: Theme.icon.xs
                        color: Theme.text.secondary
                        visible: !root.responseVisible

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.revealPassword = !root.revealPassword
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 4
                    spacing: Theme.space.md

                    Item {
                        Layout.fillWidth: true
                    }

                    DialogButton {
                        label: "Deny"
                        onClicked: root.cancelRequest()
                    }

                    DialogButton {
                        label: "Allow"
                        primary: true
                        enabled: root.responseRequired && !root.submitted
                        onClicked: root.submitResponse()
                    }
                }
            }
        }
    }

    component DialogButton: Rectangle {
        id: btn
        required property string label
        property bool primary: false
        property bool enabled: true
        signal clicked

        implicitWidth: btnLabel.implicitWidth + 24
        implicitHeight: 30
        radius: Theme.radius.md
        opacity: enabled ? 1 : 0.5
        color: primary ? (btnArea.pressed ? Qt.darker(Theme.accent, 1.15) : (btnArea.containsMouse ? Qt.lighter(Theme.accent, 1.1) : Theme.accent)) : (btnArea.pressed ? Theme.colors.overlay : (btnArea.containsMouse ? Theme.colors.raised : Theme.colors.bg))
        border.width: primary ? 0 : 1
        border.color: Theme.stroke.hairline

        Behavior on color {
            ColorAnimation {
                duration: Theme.motion.fast
            }
        }

        Text {
            id: btnLabel
            anchors.centerIn: parent
            text: btn.label
            color: btn.primary ? Theme.accentText : Theme.text.primary
            font.family: Theme.font.ui
            font.pixelSize: Theme.type.body.size
            font.weight: btn.primary ? Font.Medium : Font.Normal
        }

        MouseArea {
            id: btnArea
            anchors.fill: parent
            hoverEnabled: true
            enabled: btn.enabled
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.clicked()
        }
    }
}
