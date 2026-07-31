pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Polkit
import Quickshell.Wayland
import qs.Constants

// Password-only polkit authentication agent. Registers itself with
// polkit-1 and shows a centered card whenever an authentication request
// comes in. Only one polkit agent can be registered at a time — make sure
// nothing else (hyprpolkitagent, polkit-gnome-authentication-agent-1, etc.)
// is running before enabling this.
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
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: root
            property: "shakeOffset"
            to: 8
            duration: 50
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            target: root
            property: "shakeOffset"
            to: 0
            duration: 55
            easing.type: Easing.OutQuad
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

        function onInputPromptChanged() { root.syncFromFlow(); }
        function onResponseVisibleChanged() { root.syncFromFlow(); }

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
            color: Qt.rgba(Colors.scrim.r, Colors.scrim.g, Colors.scrim.b, 0.5)
        }

        MouseArea {
            anchors.fill: parent
            onClicked: passwordInput.forceActiveFocus()
        }

        Rectangle {
            id: card
            width: 320
            height: 148
            radius: Theme.blockRadius * 2
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: root.shakeOffset
            color: Colors.surface_container
            border.width: 1
            border.color: root.errorFlash ? Colors.error : Colors.outline_variant

            Behavior on border.color {
                ColorAnimation { duration: Theme.animations.fast }
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
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        text: PhosphorIcons.lock
                        font.family: Fonts.phosphorFont
                        font.pixelSize: 20
                        color: root.errorFlash ? Colors.error : Colors.primary
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.message
                        color: Colors.on_surface
                        font.family: Fonts.font
                        font.pixelSize: Fonts.p - 2
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    radius: Theme.blockRadius
                    color: Colors.surface_container_low
                    border.width: 1
                    border.color: passwordInput.activeFocus ? Colors.primary : Colors.outline_variant

                    Behavior on border.color {
                        ColorAnimation { duration: Theme.animations.fast }
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
                        color: root.errorFlash ? Colors.error : Colors.on_surface
                        font.family: Fonts.font
                        font.pixelSize: Fonts.p - 2
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
                        color: root.errorFlash ? Colors.error : Colors.on_surface_variant
                        opacity: root.errorFlash ? 1 : 0.6
                        font.family: Fonts.font
                        font.pixelSize: Fonts.p - 2
                        visible: passwordInput.text.length === 0
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.revealPassword ? PhosphorIcons.eyeSlash : PhosphorIcons.eye
                        font.family: Fonts.phosphorFont
                        font.pixelSize: 14
                        color: Colors.on_surface_variant
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
                    spacing: 8

                    Item { Layout.fillWidth: true }

                    component DialogButton: Rectangle {
                        id: btn
                        required property string label
                        property bool primary: false
                        property bool enabled: true
                        signal clicked

                        implicitWidth: btnLabel.implicitWidth + 24
                        implicitHeight: 30
                        radius: Theme.blockRadius
                        opacity: enabled ? 1 : 0.5
                        color: primary
                            ? (btnArea.pressed ? Qt.darker(Colors.primary, 1.15) : (btnArea.containsMouse ? Qt.lighter(Colors.primary, 1.1) : Colors.primary))
                            : (btnArea.pressed ? Colors.surface_container_highest : (btnArea.containsMouse ? Colors.surface_container_high : Colors.surface_container_low))
                        border.width: primary ? 0 : 1
                        border.color: Colors.outline_variant

                        Behavior on color {
                            ColorAnimation { duration: Theme.animations.fast }
                        }

                        Text {
                            id: btnLabel
                            anchors.centerIn: parent
                            text: btn.label
                            color: btn.primary ? Colors.on_primary : Colors.on_surface
                            font.family: Fonts.font
                            font.pixelSize: Fonts.p - 2
                            font.weight: btn.primary ? Font.Bold : Font.Normal
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
}
