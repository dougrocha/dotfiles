import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import qs.Components
import qs.Constants
import qs.Services

PopupWindow {
    id: panel

    color: "transparent"
    implicitWidth: card.cardWidth
    implicitHeight: {
        const win = anchor.window;
        return (win && win.screen) ? Math.max(400, win.screen.height - win.height - 12) : 800;
    }

    mask: Region {
        item: card
    }

    visible: Visibilities.settingsPanel

    PopupGrab {
        popup: panel
        onDismissed: Visibilities.settingsPanel = false
    }

    onVisibleChanged: {
        if (visible)
            IdleService.refresh();
    }

    component Toggle: Rectangle {
        id: toggle

        property bool checked: false

        width: 38
        height: 22
        radius: height / 2
        color: checked ? Colors.primary : Colors.surface_container_highest
        border.color: checked ? Colors.primary : Colors.outline
        border.width: 1

        Behavior on color {
            ColorAnimation {
                duration: Theme.animations.fast
            }
        }
        Behavior on border.color {
            ColorAnimation {
                duration: Theme.animations.fast
            }
        }

        Rectangle {
            width: 14
            height: 14
            radius: width / 2
            y: (parent.height - height) / 2
            x: toggle.checked ? toggle.width - width - 4 : 4
            color: toggle.checked ? Colors.on_primary : Colors.outline

            Behavior on x {
                NumberAnimation {
                    duration: Theme.animations.fast
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on color {
                ColorAnimation {
                    duration: Theme.animations.fast
                }
            }
        }
    }

    component DeviceBatteryRow: Item {
        id: deviceRow

        property string iconText: ""
        property string name: ""
        property int pct: 0
        property bool charging: false

        width: parent.width
        height: 32

        readonly property color batteryColor: pct <= 10 && !charging ? Colors.error : Colors.primary

        Text {
            id: deviceIcon
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: deviceRow.iconText
            color: deviceRow.batteryColor
            font.pixelSize: 16
            font.family: Fonts.phosphorFont
        }

        Text {
            anchors.left: deviceIcon.right
            anchors.leftMargin: 10
            anchors.right: batteryStatus.left
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            text: deviceRow.name
            color: Colors.on_surface
            font.pixelSize: Fonts.body.size
            font.family: Fonts.font
            elide: Text.ElideRight
        }

        Row {
            id: batteryStatus
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            Text {
                visible: deviceRow.charging
                anchors.verticalCenter: parent.verticalCenter
                text: PhosphorIcons.batteryCharging
                color: Colors.primary
                font.pixelSize: 13
                font.family: Fonts.phosphorFont
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 44
                height: 5
                radius: height / 2
                color: Colors.outline_variant
                clip: true

                Rectangle {
                    width: parent.width * Math.max(0, Math.min(100, deviceRow.pct)) / 100
                    height: parent.height
                    radius: parent.radius
                    color: deviceRow.batteryColor

                    Behavior on width {
                        NumberAnimation {
                            duration: Theme.animations.normal
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.animations.fast
                        }
                    }
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: 30
                horizontalAlignment: Text.AlignRight
                text: deviceRow.pct + "%"
                color: deviceRow.batteryColor
                font.pixelSize: Fonts.label.size
                font.weight: Fonts.label.weight
                font.family: Fonts.font
            }
        }
    }

    component PowerButton: Rectangle {
        id: powerButton

        property string iconText: ""
        property string label: ""
        property color accent: Colors.primary

        signal tapped

        activeFocusOnTab: true
        height: 48
        radius: Theme.blockRadius
        color: powerHover.hovered || activeFocus ? Qt.rgba(accent.r, accent.g, accent.b, 0.14) : Qt.rgba(accent.r, accent.g, accent.b, 0)
        border.color: powerHover.hovered || activeFocus ? accent : Colors.outline_variant
        border.width: 1

        Behavior on color {
            ColorAnimation {
                duration: Theme.animations.fast
            }
        }
        Behavior on border.color {
            ColorAnimation {
                duration: Theme.animations.fast
            }
        }

        Text {
            id: powerIcon
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            text: powerButton.iconText
            color: powerButton.accent
            font.pixelSize: 18
            font.family: Fonts.phosphorFont
        }

        Text {
            anchors.left: powerIcon.right
            anchors.leftMargin: 9
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            text: powerButton.label
            color: Colors.on_surface
            font.pixelSize: Fonts.body.size
            font.weight: Font.Medium
            font.family: Fonts.font
            elide: Text.ElideRight
        }

        HoverHandler {
            id: powerHover
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler {
            onTapped: powerButton.tapped()
        }
        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                powerButton.tapped();
                event.accepted = true;
            }
        }
    }

    PopupCard {
        id: card

        readonly property int cardWidth: 300

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        shown: Visibilities.settingsPanel
        onDismissed: Visibilities.settingsPanel = false

        Item {
            width: parent.width
            height: 28

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "System"
                color: Colors.on_surface
                font.pixelSize: 16
                font.family: Fonts.font
                font.weight: Font.Medium
            }
        }

        PopupDivider {}

        Rectangle {
            id: idleRow

            width: parent.width
            height: 44
            radius: Theme.blockRadius
            activeFocusOnTab: true
            color: idleHover.hovered || activeFocus ? Colors.surface_container_highest : Colors.surface_container
            border.width: activeFocus ? 1 : 0
            border.color: Colors.primary

            Behavior on color {
                ColorAnimation {
                    duration: Theme.animations.fast
                }
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.right: idleToggle.left
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                text: "Idle lock"
                color: Colors.on_surface
                font.pixelSize: Fonts.body.size
                font.weight: Font.Medium
                font.family: Fonts.font
                elide: Text.ElideRight
            }

            Toggle {
                id: idleToggle
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                checked: IdleService.active
            }

            HoverHandler {
                id: idleHover
                cursorShape: Qt.PointingHandCursor
            }
            TapHandler {
                onTapped: IdleService.toggle(true)
            }
            Keys.onPressed: function (event) {
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                    IdleService.toggle(true);
                    event.accepted = true;
                }
            }
        }

        Column {
            width: parent.width
            spacing: Theme.popup.spacing
            visible: DeviceBatteryService.hasDevices

            PopupDivider {}

            SectionLabel {
                text: "DEVICES"
            }

            Column {
                width: parent.width
                spacing: 2

                Repeater {
                    model: ScriptModel {
                        values: DeviceBatteryService.upowerDevices
                    }

                    delegate: DeviceBatteryRow {
                        required property var modelData
                        iconText: DeviceBatteryService.upowerIcon(modelData)
                        name: modelData.model
                        pct: Math.round(modelData.percentage * 100)
                        charging: modelData.state === UPowerDeviceState.Charging
                    }
                }

                Repeater {
                    model: ScriptModel {
                        values: DeviceBatteryService.bluetoothDevices
                        objectProp: "address"
                    }

                    delegate: DeviceBatteryRow {
                        required property var modelData
                        iconText: modelData.icon
                        name: modelData.name
                        pct: Math.round(modelData.battery * 100)
                    }
                }
            }
        }

        PopupDivider {
            visible: DeviceBatteryService.hasDevices
        }

        Column {
            width: parent.width
            spacing: 8

            Row {
                width: parent.width
                spacing: 8

                PowerButton {
                    width: (parent.width - 8) / 2
                    iconText: PhosphorIcons.lockSimple
                    label: "Lock"
                    accent: Colors.secondary
                    onTapped: {
                        lockProcess.running = true;
                        Visibilities.settingsPanel = false;
                    }
                }

                PowerButton {
                    width: (parent.width - 8) / 2
                    iconText: PhosphorIcons.signOut
                    label: "Log out"
                    accent: Colors.primary
                    onTapped: logoutProcess.running = true
                }
            }

            Row {
                width: parent.width
                spacing: 8

                PowerButton {
                    width: (parent.width - 8) / 2
                    iconText: PhosphorIcons.arrowCounterClockwise
                    label: "Restart"
                    accent: Colors.tertiary
                    onTapped: rebootProcess.running = true
                }

                PowerButton {
                    width: (parent.width - 8) / 2
                    iconText: PhosphorIcons.power
                    label: "Shut down"
                    accent: Colors.error
                    onTapped: shutdownProcess.running = true
                }
            }
        }
    }

    Process {
        id: lockProcess
        command: ["loginctl", "lock-session"]
    }

    Process {
        id: shutdownProcess
        command: ["sh", "-c", "hyprctl dispatch \"hl.dsp.exec_cmd([[hyprshutdown -t 'Shutting down...' --post-cmd 'shutdown -P 0']])\""]
    }

    Process {
        id: rebootProcess
        command: ["sh", "-c", "hyprctl dispatch \"hl.dsp.exec_cmd([[hyprshutdown -t 'Restarting...' --post-cmd 'systemctl reboot']])\""]
    }

    Process {
        id: logoutProcess
        command: ["sh", "-c", "hyprctl dispatch \"hl.dsp.exec_cmd([[hyprshutdown -t 'Logging out...']])\""]
    }
}
