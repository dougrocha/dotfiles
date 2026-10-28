pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Components
import qs.Constants
import qs.Services

Rectangle {
    id: card

    readonly property var request: PolkitService.request
    readonly property var identity: request.identities[request.selected] ?? null
    property bool menuOpen: false
    property int menuHighlight: 0
    property real shakePhase: 1
    readonly property real shakeX: Math.sin(shakePhase * Math.PI * 2 * Theme.motion.shakeCycles) * (1 - shakePhase) * Theme.motion.shakeDistance

    function focusField(): void {
        Qt.callLater(() => passwordField.forceActiveFocus());
    }

    function reset() {
        passwordField.text = "";
        menuOpen = false;
        focusField();
    }

    function submit() {
        if (!PolkitService.canSubmit)
            return;
        PolkitService.submit(passwordField.text);
        passwordField.text = "";
    }

    function openMenu() {
        if (!PolkitService.canChooseIdentity)
            return;
        menuHighlight = request.selected;
        menuOpen = true;
        scope.forceActiveFocus();
    }

    function choose(index) {
        menuOpen = false;
        PolkitService.selectIdentity(index);
        focusField();
    }

    function handleKey(event) {
        if (menuOpen) {
            if (event.key === Qt.Key_Escape) {
                menuOpen = false;
                focusField();
            } else if (event.key === Qt.Key_Up) {
                menuHighlight = Math.max(0, menuHighlight - 1);
            } else if (event.key === Qt.Key_Down) {
                menuHighlight = Math.min(request.identities.length - 1, menuHighlight + 1);
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                choose(menuHighlight);
            } else {
                return;
            }
        } else if (event.key === Qt.Key_Escape) {
            PolkitService.cancel();
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            submit();
        } else {
            return;
        }
        event.accepted = true;
    }

    width: 360
    height: body.implicitHeight + Theme.space.xxl * 2
    radius: Theme.radius.xl
    color: Theme.colors.surface
    border.width: 1
    border.color: Theme.stroke.hairline
    clip: true
    transform: Translate {
        x: card.shakeX
    }

    SizeMotion on height {}

    Connections {
        target: PolkitService

        function onRequestStarted() {
            shake.stop();
            card.shakePhase = 1;
            card.reset();
        }

        function onInputReset() {
            card.reset();
        }

        function onAttemptFailed() {
            passwordField.text = "";
            shake.restart();
            card.focusField();
        }
    }

    NumberAnimation {
        id: shake

        target: card
        property: "shakePhase"
        from: 0
        to: 1
        duration: Theme.motion.slow
    }

    FocusScope {
        id: scope

        anchors.fill: parent
        focus: true
        Keys.onPressed: event => card.handleKey(event)

        ColumnLayout {
            id: body

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Theme.space.xxl
            spacing: 0

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: PhosphorIcons.lock
                color: Theme.text.secondary
                font.family: Theme.font.iconFill
                font.pixelSize: Theme.icon.xxl
            }

            Text {
                Layout.fillWidth: true
                Layout.topMargin: Theme.space.lg
                text: card.request.title
                textFormat: Text.PlainText
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                maximumLineCount: 3
                elide: Text.ElideRight
                color: Theme.text.primary
                font.family: Theme.font.ui
                font.pixelSize: Theme.type.title.size
                font.weight: Theme.type.title.weight
            }

            Text {
                Layout.fillWidth: true
                Layout.topMargin: Theme.space.xs
                text: PolkitService.instruction
                textFormat: Text.PlainText
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                color: Theme.text.secondary
                font.family: Theme.font.ui
                font.pixelSize: Theme.type.body.size
                font.weight: Theme.type.body.weight
            }

            Text {
                Layout.fillWidth: true
                Layout.topMargin: Theme.space.sm
                visible: card.request.command !== ""
                text: card.request.command
                textFormat: Text.PlainText
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAnywhere
                maximumLineCount: 2
                elide: Text.ElideRight
                color: Theme.text.tertiary
                font.family: Theme.font.mono
                font.pixelSize: Theme.type.caption.size
            }

            Rectangle {
                id: form

                readonly property bool alarm: PolkitService.failed && passwordField.length === 0

                Layout.fillWidth: true
                Layout.topMargin: Theme.space.xl
                implicitHeight: formRows.implicitHeight
                radius: Theme.radius.md
                color: Theme.colors.bg
                border.width: 1
                border.color: alarm ? Theme.danger : passwordField.activeFocus || card.menuOpen ? Theme.stroke.accent : Theme.stroke.hairline
                clip: true

                Behavior on border.color {
                    ColorAnimation {
                        duration: Theme.motion.fast
                    }
                }

                ColumnLayout {
                    id: formRows

                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    FormRow {
                        visible: PolkitService.canChooseIdentity
                        label: "User name"

                        Text {
                            Layout.fillWidth: true
                            text: card.identity?.name ?? ""
                            textFormat: Text.PlainText
                            elide: Text.ElideRight
                            color: Theme.text.primary
                            font.family: Theme.font.ui
                            font.pixelSize: Theme.type.body.size
                        }

                        Text {
                            text: PhosphorIcons.caretUpDown
                            color: Theme.text.secondary
                            font.family: Theme.font.icon
                            font.pixelSize: Theme.icon.xs
                        }

                        HoverHandler {
                            cursorShape: Qt.PointingHandCursor
                        }

                        TapHandler {
                            onTapped: card.menuOpen ? card.choose(card.request.selected) : card.openMenu()
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: Theme.space.xs
                        Layout.rightMargin: Theme.space.xs
                        Layout.bottomMargin: Theme.space.xs
                        visible: card.menuOpen
                        spacing: 0

                        Repeater {
                            model: ScriptModel {
                                values: card.request.identities
                                objectProp: "key"
                            }

                            delegate: IdentityOption {}
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 1
                        visible: PolkitService.canChooseIdentity
                        color: Theme.stroke.hairline
                    }

                    FormRow {
                        label: card.request.prompt

                        TextInput {
                            id: passwordField

                            Layout.fillWidth: true
                            clip: true
                            focus: true
                            echoMode: card.request.responseVisible ? TextInput.Normal : TextInput.Password
                            passwordCharacter: "•"
                            readOnly: PolkitService.submitted
                            color: Theme.text.primary
                            selectionColor: Theme.fill.strong
                            font.family: Theme.font.ui
                            font.pixelSize: Theme.type.body.size
                        }
                    }
                }
            }

            RowLayout {
                id: statusLine

                Layout.fillWidth: true
                Layout.topMargin: Theme.space.sm
                visible: opacity > 0
                opacity: PolkitService.status ? 1 : 0
                spacing: Theme.space.xs
                transform: Translate {
                    y: (1 - statusLine.opacity) * -Theme.motion.nudge
                }

                ContentFade on opacity {}

                Text {
                    Layout.alignment: Qt.AlignTop
                    visible: PolkitService.status?.error ?? false
                    text: PhosphorIcons.warningCircle
                    color: Theme.danger
                    font.family: Theme.font.icon
                    font.pixelSize: Theme.icon.xxs
                }

                Text {
                    Layout.fillWidth: true
                    text: PolkitService.status?.text ?? ""
                    textFormat: Text.PlainText
                    wrapMode: Text.Wrap
                    color: PolkitService.status?.error ? Theme.danger : Theme.text.secondary
                    font.family: Theme.font.ui
                    font.pixelSize: Theme.type.caption.size
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: Theme.space.xl
                spacing: Theme.space.md

                DialogButton {
                    label: "Cancel"
                    onTapped: PolkitService.cancel()
                }

                DialogButton {
                    label: "Authenticate"
                    isDefault: true
                    available: PolkitService.canSubmit
                    onTapped: card.submit()
                }
            }
        }
    }

    component FormRow: RowLayout {
        required property string label

        Layout.fillWidth: true
        Layout.preferredHeight: 34
        Layout.leftMargin: Theme.space.lg
        Layout.rightMargin: Theme.space.lg
        spacing: Theme.space.md

        Text {
            Layout.preferredWidth: 76
            text: parent.label
            textFormat: Text.PlainText
            elide: Text.ElideRight
            color: Theme.text.secondary
            font.family: Theme.font.ui
            font.pixelSize: Theme.type.body.size
        }
    }

    component IdentityOption: Rectangle {
        id: option

        required property var modelData
        readonly property bool highlighted: modelData.key === card.menuHighlight || optionHover.hovered

        Layout.fillWidth: true
        implicitHeight: 28
        radius: Theme.radius.sm
        color: highlighted ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

        Behavior on color {
            ColorAnimation {
                duration: Theme.motion.fast
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.space.sm
            anchors.rightMargin: Theme.space.sm
            spacing: Theme.space.sm

            Text {
                Layout.preferredWidth: Theme.icon.xs
                text: option.modelData.key === card.request.selected ? PhosphorIcons.check : ""
                color: Theme.accent
                font.family: Theme.font.icon
                font.pixelSize: Theme.icon.xs
            }

            Text {
                text: option.modelData.isGroup ? PhosphorIcons.users : PhosphorIcons.user
                color: Theme.text.secondary
                font.family: Theme.font.icon
                font.pixelSize: Theme.icon.xs
            }

            Text {
                Layout.fillWidth: true
                text: option.modelData.name
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: Theme.text.primary
                font.family: Theme.font.ui
                font.pixelSize: Theme.type.body.size
            }
        }

        HoverHandler {
            id: optionHover

            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: card.choose(option.modelData.key)
        }
    }

    component DialogButton: Rectangle {
        id: button

        required property string label
        property bool isDefault: false
        property bool available: true

        signal tapped

        Layout.fillWidth: true
        Layout.preferredWidth: 1
        implicitHeight: 30
        radius: Theme.radius.md
        opacity: available ? 1 : 0.5
        color: isDefault ? (buttonTap.pressed ? Qt.darker(Theme.accent, 1.15) : buttonHover.hovered ? Qt.lighter(Theme.accent, 1.08) : Theme.accent) : buttonTap.pressed || buttonHover.hovered ? Theme.fill.strong : Theme.fill.press

        Behavior on color {
            ColorAnimation {
                duration: Theme.motion.fast
            }
        }

        Text {
            anchors.centerIn: parent
            text: button.label
            color: button.isDefault ? Theme.accentText : Theme.text.primary
            font.family: Theme.font.ui
            font.pixelSize: Theme.type.body.size
            font.weight: button.isDefault ? Theme.type.title.weight : Theme.type.body.weight
        }

        HoverHandler {
            id: buttonHover

            enabled: button.available
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            id: buttonTap

            enabled: button.available
            onTapped: button.tapped()
        }
    }
}
