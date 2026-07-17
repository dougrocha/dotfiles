import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
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

    property bool audioSwitcherOpen: false

    PopupGrab {
        popup: panel
        onDismissed: Visibilities.settingsPanel = false
    }

    onVisibleChanged: {
        Visibilities.settingsPanel = visible;
        if (visible) {
            IdleService.refresh();
            SunsetService.refresh();
        } else {
            audioSwitcherOpen = false;
        }
    }

    component Tile: Rectangle {
        property string label: ""
        property bool active: false
        property color accent: Colors.primary

        signal tapped

        height: 28
        radius: Theme.blockRadius
        color: active ? Qt.rgba(accent.r, accent.g, accent.b, 0.15) : tileHover.hovered ? Colors.surface_container_high : Colors.surface_container
        border.color: (active || tileHover.hovered) ? accent : Colors.outline_variant
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
            anchors.centerIn: parent
            text: parent.label
            color: (parent.active || tileHover.hovered) ? parent.accent : Colors.on_surface_variant
            font.pixelSize: Fonts.p - 2
            font.family: Fonts.font
            Behavior on color {
                ColorAnimation {
                    duration: Theme.animations.fast
                }
            }
        }

        HoverHandler {
            id: tileHover
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler {
            onTapped: parent.tapped()
        }
    }

    component PowerTile: Rectangle {
        property string iconText: ""
        property color iconColor: Colors.on_surface_variant

        signal tapped

        height: 36
        radius: Theme.blockRadius
        color: pwHover.hovered ? Colors.surface_container_high : Colors.surface_container

        Behavior on color {
            ColorAnimation {
                duration: Theme.animations.fast
            }
        }

        Text {
            anchors.centerIn: parent
            text: parent.iconText
            color: parent.iconColor
            font.pixelSize: 22
            font.family: Fonts.phosphorFont
        }

        HoverHandler {
            id: pwHover
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler {
            onTapped: parent.tapped()
        }
    }

    component SlimSlider: Item {
        id: slimRoot

        property string iconText: ""
        property string labelText: ""
        property real sliderValue: 0
        property real sliderMax: 1.5
        property bool muted: false
        property string muteIcon: ""
        property string mutedIcon: ""

        signal moved(real value)
        signal muteToggled

        implicitHeight: slimCol.implicitHeight

        Column {
            id: slimCol
            width: parent.width
            spacing: 4

            Item {
                width: parent.width
                height: 16

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: slimRoot.iconText
                    color: Colors.primary
                    font.pixelSize: Fonts.h5
                    font.family: Fonts.iconFont
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 26
                    anchors.verticalCenter: parent.verticalCenter
                    text: slimRoot.labelText
                    color: Colors.on_surface_variant
                    font.pixelSize: Fonts.p - 2
                    font.family: Fonts.font
                }

                Text {
                    id: pctLabel
                    anchors.right: muteBtn.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: Math.round(slimRoot.sliderValue * 100) + "%"
                    color: Colors.on_surface_variant
                    font.pixelSize: Fonts.p - 2
                    font.family: Fonts.font
                }

                Text {
                    id: muteBtn
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: slimRoot.muted ? slimRoot.mutedIcon : slimRoot.muteIcon
                    color: Colors.primary
                    font.pixelSize: Fonts.h5
                    font.family: Fonts.iconFont
                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }
                    TapHandler {
                        onTapped: slimRoot.muteToggled()
                    }
                }
            }

            Slider {
                id: slider
                width: parent.width
                from: 0
                to: slimRoot.sliderMax
                value: slimRoot.sliderValue
                onMoved: slimRoot.moved(value)

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }

                background: Rectangle {
                    x: slider.leftPadding
                    y: slider.topPadding + slider.availableHeight / 2 - height / 2
                    width: slider.availableWidth
                    height: 3
                    radius: 2
                    color: Colors.outline_variant

                    Rectangle {
                        width: slider.visualPosition * parent.width
                        height: parent.height
                        color: Colors.primary
                        radius: 2

                        Behavior on width {
                            NumberAnimation {
                                duration: 80
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }

                handle: Rectangle {
                    x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                    y: slider.topPadding + slider.availableHeight / 2 - height / 2
                    implicitWidth: 12
                    implicitHeight: 12
                    radius: 6
                    color: slider.pressed ? Colors.primary_fixed : Colors.primary
                }
            }
        }
    }

    Rectangle {
        id: card

        property real reveal: Visibilities.settingsPanel ? 1 : 0
        Behavior on reveal {
            NumberAnimation {
                duration: Visibilities.settingsPanel ? 160 : 120
                easing.type: Visibilities.settingsPanel ? Easing.OutCubic : Easing.InCubic
            }
        }

        readonly property int cardWidth: 280
        readonly property int cardMargin: 12

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: col.implicitHeight + cardMargin * 2
        radius: 12
        color: Colors.surface_container
        opacity: reveal
        transform: Translate {
            y: (1 - card.reveal) * -6
        }

        focus: Visibilities.settingsPanel
        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Escape) {
                Visibilities.settingsPanel = false;
                event.accepted = true;
            }
        }

        Column {
            id: col
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: card.cardMargin
            spacing: 10

            Item {
                width: parent.width
                height: 24

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Settings"
                    color: Colors.on_surface
                    font.pixelSize: Fonts.h4
                    font.family: Fonts.font
                    font.weight: Font.DemiBold
                }

                Rectangle {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: 24
                    height: 24
                    radius: 12
                    color: closeHover.hovered ? Colors.surface_container_high : "transparent"
                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.animations.fast
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: Icons.closeSmall
                        color: Colors.on_surface_variant
                        font.family: Fonts.iconFont
                        font.pixelSize: 18
                    }

                    HoverHandler {
                        id: closeHover
                        cursorShape: Qt.PointingHandCursor
                    }
                    TapHandler {
                        onTapped: Visibilities.settingsPanel = false
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Colors.outline_variant
            }

            Text {
                text: "AUDIO"
                color: Colors.on_surface_variant
                font.pixelSize: Fonts.p - 3
                font.family: Fonts.font
                font.letterSpacing: 1
                font.weight: Font.Medium
            }

            SlimSlider {
                width: parent.width
                iconText: Icons.speaker
                labelText: "Speakers"
                sliderValue: AudioService.volume
                muted: AudioService.muted
                muteIcon: Icons.volumeUp
                mutedIcon: Icons.volumeMute
                onMoved: value => AudioService.setVolume(value)
                onMuteToggled: AudioService.toggleMute()
            }

            SlimSlider {
                width: parent.width
                iconText: Icons.mic
                labelText: "Microphone"
                sliderValue: AudioService.sourceVolume
                muted: AudioService.sourceMuted
                muteIcon: Icons.mic
                mutedIcon: Icons.micOff
                onMoved: value => AudioService.setSourceVolumeValue(value)
                onMuteToggled: AudioService.toggleSourceMute()
            }

            // doesn't create a gap when the list collapses to height 0
            Column {
                width: parent.width
                spacing: 4

                Tile {
                    width: parent.width
                    label: (AudioService.sink ? (AudioService.sink.nickname || AudioService.sink.description || AudioService.sink.name || "Unknown") : "No device") + (panel.audioSwitcherOpen ? "  ▾" : "  ▸")
                    active: panel.audioSwitcherOpen
                    onTapped: panel.audioSwitcherOpen = !panel.audioSwitcherOpen
                }

                Item {
                    width: parent.width
                    height: panel.audioSwitcherOpen ? deviceColumn.implicitHeight : 0
                    clip: true

                    Behavior on height {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }

                    Column {
                        id: deviceColumn
                        width: parent.width
                        spacing: 2
                        topPadding: 4

                        Repeater {
                            model: ScriptModel {
                                values: AudioService.sinks
                                objectProp: "id"
                            }

                            delegate: Rectangle {
                                required property var modelData
                                readonly property bool isActive: AudioService.sink && modelData.id === AudioService.sink.id
                                readonly property string displayName: modelData.nickname || modelData.description || modelData.name

                                width: deviceColumn.width
                                height: 28
                                radius: Theme.blockRadius
                                color: sinkHover.hovered ? Colors.surface_container_high : "transparent"
                                Behavior on color {
                                    ColorAnimation {
                                        duration: Theme.animations.fast
                                    }
                                }

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    width: 6
                                    height: 6
                                    radius: 3
                                    color: isActive ? Colors.primary : Colors.outline
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 24
                                    anchors.right: parent.right
                                    anchors.rightMargin: 10
                                    text: displayName
                                    color: isActive ? Colors.primary : Colors.on_surface_variant
                                    font.pixelSize: Fonts.p - 2
                                    font.family: Fonts.font
                                    font.weight: isActive ? Font.Medium : Font.Normal
                                    elide: Text.ElideRight
                                }

                                HoverHandler {
                                    id: sinkHover
                                    cursorShape: Qt.PointingHandCursor
                                }
                                TapHandler {
                                    onTapped: {
                                        AudioService.setAudioSink(modelData);
                                        panel.audioSwitcherOpen = false;
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Colors.outline_variant
            }

            Text {
                text: "CONNECTIONS"
                color: Colors.on_surface_variant
                font.pixelSize: Fonts.p - 3
                font.family: Fonts.font
                font.letterSpacing: 1
                font.weight: Font.Medium
            }

            Rectangle {
                width: parent.width
                height: 28
                radius: Theme.blockRadius
                color: btHover.hovered ? Colors.surface_container_high : Colors.surface_container
                border.color: BluetoothService.bluetoothEnabled ? Colors.primary : Colors.outline_variant
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
                    id: btIcon
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: BluetoothService.hasConnectedDevices ? Icons.bluetoothConnected : Icons.bluetooth
                    color: BluetoothService.bluetoothEnabled ? Colors.primary : Colors.on_surface_variant
                    font.pixelSize: Fonts.h5
                    font.family: Fonts.iconFont
                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.animations.fast
                        }
                    }
                }

                Text {
                    anchors.left: btIcon.right
                    anchors.leftMargin: 8
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                        if (!BluetoothService.bluetoothEnabled)
                            return "Off";
                        if (BluetoothService.connectedDevices.length === 0)
                            return "Not connected";
                        return BluetoothService.connectedDevices.map(d => d.name).join(", ");
                    }
                    color: BluetoothService.bluetoothEnabled ? Colors.on_surface : Colors.on_surface_variant
                    font.pixelSize: Fonts.p - 2
                    font.family: Fonts.font
                    elide: Text.ElideRight
                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.animations.fast
                        }
                    }
                }

                HoverHandler {
                    id: btHover
                    cursorShape: Qt.PointingHandCursor
                }
                TapHandler {
                    onTapped: {
                        bluetoothProcess.running = true;
                        Visibilities.settingsPanel = false;
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Colors.outline_variant
            }

            Text {
                text: "QUICK"
                color: Colors.on_surface_variant
                font.pixelSize: Fonts.p - 3
                font.family: Fonts.font
                font.letterSpacing: 1
                font.weight: Font.Medium
            }

            Row {
                width: parent.width
                spacing: 8

                Tile {
                    width: (parent.width - 8) / 2
                    label: "Idle"
                    active: IdleService.active
                    onTapped: IdleService.toggle()
                }

                Tile {
                    width: (parent.width - 8) / 2
                    label: "Night"
                    active: SunsetService.active
                    onTapped: SunsetService.toggle()
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Colors.outline_variant
            }

            Row {
                width: parent.width
                spacing: 8

                PowerTile {
                    width: (parent.width - 24) / 4
                    iconText: PhosphorIcons.power
                    iconColor: Colors.error
                    onTapped: shutdownProcess.running = true
                }

                PowerTile {
                    width: (parent.width - 24) / 4
                    iconText: PhosphorIcons.arrowCounterClockwise
                    iconColor: Colors.tertiary
                    onTapped: rebootProcess.running = true
                }

                PowerTile {
                    width: (parent.width - 24) / 4
                    iconText: PhosphorIcons.signOut
                    iconColor: Colors.primary
                    onTapped: logoutProcess.running = true
                }

                PowerTile {
                    width: (parent.width - 24) / 4
                    iconText: PhosphorIcons.lockSimple
                    iconColor: Colors.secondary
                    onTapped: {
                        lockProcess.running = true;
                        Visibilities.settingsPanel = false;
                    }
                }
            }
        }
    }

    Process {
        id: bluetoothProcess
        command: ["launch-or-focus-tui", "bluetui"]
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
