import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Constants
import qs.Services
import qs.Modules.Notifications
import Quickshell.Widgets

PopupWindow {
    id: settingsPanel

    property bool audioSwitcherOpen: false

    implicitHeight: contentLayout.implicitHeight + Theme.panelMargin * 2

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 80
            easing.type: Easing.OutExpo
        }
    }

    onVisibleChanged: {
        if (visible) {
            IdleService.refresh();
            SunsetService.refresh();
        } else {
            audioSwitcherOpen = false;
        }
    }

    implicitWidth: 420
    color: "transparent"

    Rectangle {
        id: contentRect

        anchors.fill: parent
        color: Colors.surface_container
        radius: 12

        transformOrigin: Item.Top
        scale: settingsPanel.visible ? 1.0 : 0.92
        opacity: settingsPanel.visible ? 1.0 : 0.0

        Behavior on scale {
            SpringAnimation {
                spring: 12.0
                damping: 0.7
                mass: 0.4
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 80
                easing.type: Easing.OutCubic
            }
        }
    }

    component SettingsSlider: RowLayout {
        id: sliderRow

        property string iconText: ""
        property string labelText: ""
        property real sliderValue: 0
        property real sliderMax: 1.5
        property bool muted: false
        property string muteIcon: ""
        property string mutedIcon: ""

        signal moved(real value)
        signal muteToggled

        Layout.fillWidth: true
        spacing: 12

        Text {
            text: sliderRow.iconText
            color: Colors.primary
            font.pixelSize: Fonts.h3
            font.family: Fonts.iconFont
            Layout.alignment: Qt.AlignVCenter
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: sliderRow.labelText
                    color: Colors.on_surface_variant
                    font.pixelSize: Fonts.p
                    font.family: Fonts.font
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: Math.round(sliderRow.sliderValue * 100) + "%"
                    color: Colors.on_surface_variant
                    font.pixelSize: Fonts.p
                    font.family: Fonts.font
                }

                Text {
                    text: sliderRow.muted ? sliderRow.mutedIcon : sliderRow.muteIcon
                    color: Colors.primary
                    font.pixelSize: Fonts.h3
                    font.family: Fonts.iconFont

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        onTapped: sliderRow.muteToggled()
                    }
                }
            }

            Slider {
                id: slider
                Layout.fillWidth: true
                from: 0
                to: sliderRow.sliderMax
                value: sliderRow.sliderValue
                onMoved: sliderRow.moved(value)

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }

                background: Rectangle {
                    x: slider.leftPadding
                    y: slider.topPadding + slider.availableHeight / 2 - height / 2
                    width: slider.availableWidth
                    height: 4
                    radius: 2
                    color: Colors.outline_variant

                    Rectangle {
                        width: slider.visualPosition * parent.width
                        height: parent.height
                        color: Colors.primary
                        radius: 2

                        Behavior on width {
                            NumberAnimation {
                                duration: 100
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }

                handle: Rectangle {
                    x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                    y: slider.topPadding + slider.availableHeight / 2 - height / 2
                    implicitWidth: 14
                    implicitHeight: 14
                    radius: 7
                    color: slider.pressed ? Colors.primary_fixed : Colors.primary

                    Behavior on x {
                        NumberAnimation {
                            duration: 100
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }

    component SettingsIconButton: Rectangle {
        id: btn

        property string iconText: ""
        property string labelText: ""
        property color iconColor: Colors.primary
        property int iconSize: Fonts.h4
        property bool active: false
        property color activeBackground: "transparent"
        property color activeIconColor: iconColor

        signal tapped

        Layout.fillWidth: true
        Layout.preferredHeight: labelText !== "" ? 52 : 44
        radius: Theme.blockRadius
        color: active ? activeBackground : (hover.hovered ? Colors.surface_container_high : Colors.surface_container)
        border.width: 1
        border.color: active ? Qt.rgba(btn.activeIconColor.r, btn.activeIconColor.g, btn.activeIconColor.b, 0.35) : "transparent"

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

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 2

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: btn.iconText
                color: btn.active ? btn.activeIconColor : btn.iconColor
                font.pixelSize: btn.iconSize
                font.family: Fonts.iconFont

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animations.fast
                    }
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: btn.labelText
                color: btn.active ? btn.activeIconColor : Colors.on_surface_variant
                font.pixelSize: Fonts.p - 2
                font.family: Fonts.font
                visible: btn.labelText !== ""

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animations.fast
                    }
                }
            }
        }

        HoverHandler {
            id: hover
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: btn.tapped()
        }
    }

    component SettingsConnectionRow: Rectangle {
        id: connRow

        property string iconText: ""
        property string title: ""
        property string subtitle: ""
        property bool on: false
        property color accent: Colors.primary

        signal toggled
        signal tapped

        Layout.fillWidth: true
        implicitHeight: 52
        radius: Theme.blockRadius
        color: connHover.hovered ? Colors.surface_container_high : Colors.surface_container

        Behavior on color {
            ColorAnimation {
                duration: Theme.animations.fast
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 12

            Rectangle {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                radius: 16
                color: connRow.on ? Qt.rgba(connRow.accent.r, connRow.accent.g, connRow.accent.b, 0.2) : Colors.surface_container_high

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animations.fast
                    }
                }

                Text {
                    width: parent.width
                    height: parent.height
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: connRow.iconText
                    color: connRow.on ? connRow.accent : Colors.outline
                    font.pixelSize: Fonts.h4
                    font.family: Fonts.iconFont

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.animations.fast
                        }
                    }
                }

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: connRow.toggled()
                }
            }

            ColumnLayout {
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: connRow.title
                    color: Colors.on_surface
                    font.pixelSize: Fonts.p
                    font.family: Fonts.font
                    font.weight: Font.DemiBold
                }

                Text {
                    text: connRow.subtitle
                    color: Colors.on_surface_variant
                    font.pixelSize: Fonts.p - 2
                    font.family: Fonts.font
                    visible: connRow.subtitle !== ""
                    Layout.preferredHeight: connRow.subtitle !== "" ? implicitHeight : 0
                }
            }

            Text {
                text: Icons.chevronRight
                color: Colors.on_surface_variant
                font.pixelSize: Fonts.h4
                font.family: Fonts.iconFont
            }
        }

        HoverHandler {
            id: connHover
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: connRow.tapped()
        }
    }

    ColumnLayout {
        id: contentLayout

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Theme.panelMargin
        spacing: 16

        // Header
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "Settings"
                color: Colors.primary
                font.pixelSize: Fonts.h1
                font.family: Fonts.font
                font.bold: true
            }

            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                implicitWidth: 32
                implicitHeight: 32
                radius: 16
                color: closeHover.hovered ? Colors.surface_container_high : Colors.surface_container

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animations.fast
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: Icons.closeSmall
                    color: Colors.primary
                    font.family: Fonts.iconFont
                    font.pixelSize: 22
                }

                HoverHandler {
                    id: closeHover
                    cursorShape: Qt.PointingHandCursor
                }
                TapHandler {
                    onTapped: settingsPanel.visible = false
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Colors.outline_variant
        }

        // Speakers
        SettingsSlider {
            iconText: Icons.speaker
            labelText: "Speakers"
            sliderValue: AudioService.volume
            muted: AudioService.muted
            muteIcon: Icons.volumeUp
            mutedIcon: Icons.volumeMute
            onMoved: value => AudioService.setVolume(value)
            onMuteToggled: AudioService.toggleMute()
        }

        // Microphone
        SettingsSlider {
            iconText: Icons.mic
            labelText: "Microphone"
            sliderValue: AudioService.sourceVolume
            muted: AudioService.sourceMuted
            muteIcon: Icons.mic
            mutedIcon: Icons.micOff
            onMoved: value => AudioService.setSourceVolumeValue(value)
            onMuteToggled: AudioService.toggleSourceMute()
        }

        // Connection Rows
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                SettingsConnectionRow {
                    Layout.fillWidth: true
                    iconText: Icons.speaker
                    title: "Speakers"
                    subtitle: AudioService.sink ? (AudioService.sink.nickname || AudioService.sink.description || AudioService.sink.name || "") : ""
                    on: !AudioService.muted
                    accent: Colors.primary
                    onToggled: AudioService.toggleMute()
                    onTapped: settingsPanel.audioSwitcherOpen = !settingsPanel.audioSwitcherOpen
                }

                Item {
                    id: audioSwitcherWrapper

                    property real sectionHeight: 0

                    Layout.fillWidth: true
                    Layout.preferredHeight: sectionHeight
                    clip: true

                    Behavior on sectionHeight {
                        NumberAnimation {
                            duration: 220
                            easing.type: Easing.OutExpo
                        }
                    }

                    Connections {
                        target: settingsPanel
                        function onAudioSwitcherOpenChanged() {
                            audioSwitcherWrapper.sectionHeight = settingsPanel.audioSwitcherOpen ? audioSwitcherColumn.implicitHeight : 0;
                        }
                    }

                    Column {
                        id: audioSwitcherColumn
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

                                width: audioSwitcherColumn.width
                                height: Theme.blockHeight + 8
                                radius: Theme.blockRadius
                                color: sinkHover.hovered ? Colors.surface_container_high : "transparent"

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 56
                                    anchors.rightMargin: 12
                                    spacing: 8

                                    Rectangle {
                                        width: 8
                                        height: 8
                                        radius: 4
                                        color: isActive ? Colors.primary : Colors.outline
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: displayName
                                        color: isActive ? Colors.primary : Colors.on_surface_variant
                                        font.pixelSize: Fonts.p
                                        font.family: Fonts.font
                                        font.bold: isActive
                                        elide: Text.ElideRight
                                    }
                                }

                                HoverHandler {
                                    id: sinkHover
                                    cursorShape: Qt.PointingHandCursor
                                }
                                TapHandler {
                                    onTapped: {
                                        AudioService.setAudioSink(modelData);
                                        settingsPanel.audioSwitcherOpen = false;
                                    }
                                }
                            }
                        }

                        Item {
                            width: 1
                            height: 4
                        }
                    }
                }
            }

            SettingsConnectionRow {
                Layout.fillWidth: true
                iconText: Icons.settingsBluetooth
                title: "Bluetooth"
                subtitle: BluetoothService.statusText
                on: BluetoothService.bluetoothEnabled
                accent: Colors.primary
                onToggled: BluetoothService.togglePower()
                onTapped: {
                    bluetoothProcess.running = true;
                    settingsPanel.visible = false;
                }
            }
        }

        // Utility Buttons Row
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            SettingsIconButton {
                iconText: Icons.lockClock
                labelText: "Idle"
                iconColor: IdleService.active ? Colors.tertiary : Colors.outline
                onTapped: IdleService.toggle()
            }

            SettingsIconButton {
                iconText: SunsetService.active ? Icons.wbSunny : Icons.nightlight
                labelText: "Night"
                iconColor: SunsetService.active ? Colors.tertiary_container : Colors.outline
                onTapped: SunsetService.toggle()
            }
        }

        // Notifications
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Notifications"
                    color: Colors.on_surface
                    font.family: Fonts.font
                    font.pixelSize: Fonts.h4
                    font.weight: Font.DemiBold
                }

                Item {
                    Layout.fillWidth: true
                }

                Rectangle {
                    implicitWidth: clearLabel.implicitWidth + 16
                    implicitHeight: clearLabel.implicitHeight + 8
                    radius: Theme.blockRadius
                    color: clearHover.hovered ? Colors.surface_container_high : Colors.surface_container

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.animations.fast
                        }
                    }

                    Text {
                        id: clearLabel
                        anchors.centerIn: parent
                        text: "Clear"
                        color: clearHover.hovered ? Colors.primary : Colors.on_surface_variant
                        font.family: Fonts.font
                        font.pixelSize: Fonts.p

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.animations.fast
                            }
                        }
                    }

                    HoverHandler {
                        id: clearHover
                        cursorShape: Qt.PointingHandCursor
                    }
                    TapHandler {
                        onTapped: NotificationService.clearHistory()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Colors.outline_variant
            }

            ListView {
                id: historyList

                Layout.fillWidth: true
                Layout.preferredHeight: 320
                topMargin: 6
                bottomMargin: 6
                spacing: Theme.notifications.spacing
                clip: true

                model: ScriptModel {
                    values: NotificationService.history
                    objectProp: "id"
                }

                add: Transition {
                    ParallelAnimation {
                        NumberAnimation {
                            property: "opacity"
                            from: 0
                            to: 1
                            duration: Theme.animations.normal
                            easing.type: Easing.OutCubic
                        }
                        NumberAnimation {
                            property: "x"
                            from: 40
                            to: 0
                            duration: Theme.animations.normal
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                remove: Transition {
                    ParallelAnimation {
                        NumberAnimation {
                            property: "opacity"
                            to: 0
                            duration: Theme.animations.normal
                            easing.type: Easing.OutCubic
                        }
                        NumberAnimation {
                            property: "x"
                            to: 40
                            duration: Theme.animations.normal
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                displaced: Transition {
                    NumberAnimation {
                        property: "y"
                        duration: Theme.animations.slow
                        easing.type: Easing.OutCubic
                    }
                }

                delegate: NotificationCard {
                    width: ListView.view.width
                }

                Text {
                    anchors.centerIn: parent
                    text: "No notifications"
                    color: Colors.on_surface_variant
                    font.family: Fonts.font
                    font.pixelSize: Fonts.p
                    visible: historyList.count === 0
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Colors.outline_variant
        }

        // Power Buttons Row
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            SettingsIconButton {
                iconText: Icons.powerSettingsNew
                iconColor: Colors.error
                iconSize: Fonts.h1
                onTapped: shutdownProcess.running = true
            }

            SettingsIconButton {
                iconText: Icons.restartAlt
                iconColor: Colors.tertiary
                iconSize: Fonts.h1
                onTapped: rebootProcess.running = true
            }

            SettingsIconButton {
                iconText: Icons.logout
                iconColor: Colors.primary
                iconSize: Fonts.h1
                onTapped: logoutProcess.running = true
            }
        }
    }

    Process {
        id: bluetoothProcess
        command: ["launch-or-focus-tui", "bluetui"]
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
