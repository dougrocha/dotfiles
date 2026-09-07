pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Components
import qs.Constants
import qs.Modules.Popups
import qs.Services
import qs.Widgets

Variants {
    id: root
    model: Theme.primaryScreens

    delegate: PanelWindow {
        id: overlay

        required property var modelData
        screen: modelData

        readonly property var clockFormats: ["h:mmAP", "ddd h:mmAP", "MMM d  h:mmAP"]

        function cycleClockFormat() {
            const next = (clockFormats.indexOf(SettingsService.clockFormat) + 1) % clockFormats.length;
            SettingsService.clockFormat = clockFormats[next];
        }

        function formatTime(seconds) {
            if (!seconds || seconds < 0)
                return "0:00";
            const mins = Math.floor(seconds / 60);
            const secs = Math.floor(seconds % 60);
            return mins + ":" + (secs < 10 ? "0" : "") + secs;
        }

        color: "transparent"
        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: 560
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs.island"

        readonly property bool revealed: Visibilities.barRevealed || IslandService.osdActive || IslandService.songNotif

        mask: Region {
            x: pill.x
            y: slide.y + pill.y
            width: overlay.revealed ? pill.width : 0
            height: overlay.revealed ? pill.height : 0
        }

        HyprlandFocusGrab {
            windows: [overlay]
            active: overlay.visible && Visibilities.musicPanel
            onCleared: Visibilities.musicPanel = false
        }

        Item {
            id: slide
            width: parent.width
            height: parent.height
            y: overlay.revealed ? 0 : -(pill.y + pill.height)

            Behavior on y {
                NumberAnimation {
                    duration: Theme.motion.normal
                    easing.type: Theme.motion.easeStandard
                }
            }

            Rectangle {
                id: pill

                readonly property string activity: IslandService.activity
                readonly property bool full: Visibilities.musicPanel
                readonly property bool notif: !full && IslandService.songNotif && !IslandService.osdActive
                property bool recDetails: false
                readonly property int compactHeight: Theme.topBarHeight - 8

                readonly property int inset: 16

                readonly property int targetHeight: full ? fullContent.implicitHeight + inset * 2 : notif ? notifContent.implicitHeight + inset * 2 : recDetails ? compactHeight + recArea.implicitHeight + 12 : compactHeight

                property int tab: 0

                property real tabProgress: tab

                Behavior on tabProgress {
                    NumberAnimation {
                        duration: Theme.motion.normal
                        easing.type: Theme.motion.easeSmooth
                    }
                }

                onActivityChanged: recDetails = false

                onTabChanged: if (tab === 1)
                    calendarView.reset()
                onFullChanged: {
                    if (full)
                        recDetails = false;
                    if (full && tab === 1)
                        calendarView.reset();
                }

                anchors.horizontalCenter: parent.horizontalCenter
                y: 4

                width: full ? (tab === 0 ? 560 : 420) : notif ? 380 : compactRow.implicitWidth + 28
                height: targetHeight
                radius: full ? Theme.radius.xxl : notif ? Theme.radius.xl : recDetails ? Theme.radius.lg : compactHeight / 2
                color: pill.full ? Theme.colors.overlay : Theme.colors.surface
                clip: true

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }
                TapHandler {
                    onTapped: {
                        if (pill.notif)
                            IslandService.dismissSongNotif();
                        Visibilities.openMusicPanel();
                    }
                }

                Behavior on width {
                    NumberAnimation {
                        duration: Theme.motion.normal
                        easing.type: Theme.motion.easeStandard
                    }
                }
                Behavior on height {
                    NumberAnimation {
                        duration: Theme.motion.normal
                        easing.type: Theme.motion.easeStandard
                    }
                }
                Behavior on radius {
                    NumberAnimation {
                        duration: Theme.motion.fast
                        easing.type: Theme.motion.easeStandard
                    }
                }

                ClippingRectangle {
                    anchors.fill: parent
                    radius: pill.radius
                    color: "transparent"
                    opacity: pill.notif ? 1 : pill.full ? Math.max(0, 1 - pill.tabProgress * 2) : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.motion.fast
                        }
                    }

                    CrossfadeImage {
                        id: backgroundArt
                        anchors.fill: parent
                        source: IslandService.trackArtUrl || ""
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            blurEnabled: true
                            blurMax: 48
                            blur: 1
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: Theme.withAlpha(Theme.shadow, 0.6)
                        visible: backgroundArt.ready
                    }
                }

                Row {
                    id: compactRow
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: (pill.compactHeight - height) / 2
                    height: 20
                    spacing: Theme.space.md
                    opacity: (pill.full || pill.notif) ? 0 : 1
                    visible: opacity > 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.motion.fast
                        }
                    }

                    ClockWidget {
                        anchors.verticalCenter: parent.verticalCenter
                        format: SettingsService.clockFormat
                        color: clockHover.hovered ? Theme.text.primary : Theme.text.secondary
                        font.pixelSize: Theme.type.mono.size
                        font.family: Theme.font.mono
                        font.weight: Theme.type.mono.weight
                        font.letterSpacing: Theme.type.mono.tracking

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.motion.fast
                            }
                        }

                        HoverHandler {
                            id: clockHover
                            cursorShape: Qt.PointingHandCursor
                        }

                        TapHandler {
                            acceptedButtons: Qt.RightButton
                            onTapped: overlay.cycleClockFormat()
                        }
                    }

                    Rectangle {
                        visible: pill.activity !== "idle" || AudioService.micInUse
                        anchors.verticalCenter: parent.verticalCenter
                        width: 1
                        height: 14
                        color: Theme.stroke.hairline
                    }

                    Item {
                        id: musicTextClip
                        visible: pill.activity === "music" || (pill.activity === "recording" && IslandService.musicAvailable)
                        anchors.verticalCenter: parent.verticalCenter
                        width: Math.min(musicText.implicitWidth, 360)
                        height: musicText.implicitHeight
                        clip: true

                        Text {
                            id: musicText
                            text: MprisService.nowPlaying(IslandService.trackTitle, IslandService.trackArtist)
                            color: Theme.text.primary
                            font.pixelSize: Theme.type.body.size
                            font.family: Theme.font.ui
                            font.weight: Font.Medium

                            readonly property real overflow: Math.max(0, implicitWidth - musicTextClip.width)

                            readonly property bool scrolling: musicText.overflow > 0 && musicTextClip.visible && overlay.revealed

                            onTextChanged: x = 0
                            onScrollingChanged: if (!musicText.scrolling)
                                x = 0

                            SequentialAnimation on x {
                                running: musicText.scrolling
                                loops: Animation.Infinite
                                PauseAnimation {
                                    duration: 2000
                                }
                                NumberAnimation {
                                    from: 0
                                    to: -musicText.overflow
                                    duration: musicText.overflow * 40
                                    easing.type: Theme.motion.easeSmooth
                                }
                                PauseAnimation {
                                    duration: 2000
                                }
                                NumberAnimation {
                                    from: -musicText.overflow
                                    to: 0
                                    duration: musicText.overflow * 40
                                    easing.type: Theme.motion.easeSmooth
                                }
                            }
                        }

                        HoverHandler {
                            cursorShape: Qt.PointingHandCursor
                        }
                    }

                    Rectangle {
                        visible: AudioService.micInUse
                        anchors.verticalCenter: parent.verticalCenter
                        width: 8
                        height: 8
                        radius: Theme.radius.xs
                        color: Theme.caution
                    }

                    Text {
                        visible: pill.activity === "osd"
                        anchors.verticalCenter: parent.verticalCenter
                        text: {
                            if (IslandService.osdMode === "mic")
                                return IslandService.osdMuted ? PhosphorIcons.microphoneSlash : PhosphorIcons.microphone;
                            if (IslandService.osdMuted)
                                return PhosphorIcons.speakerSlash;
                            if (IslandService.osdLevel === 0)
                                return PhosphorIcons.speakerNone;
                            return IslandService.osdLevel < 0.5 ? PhosphorIcons.speakerLow : PhosphorIcons.speakerHigh;
                        }
                        color: IslandService.osdMuted ? Theme.text.secondary : Theme.accent
                        font.pixelSize: Theme.icon.md
                        font.family: Theme.font.icon
                    }
                    Rectangle {
                        visible: pill.activity === "osd"
                        anchors.verticalCenter: parent.verticalCenter
                        width: 120
                        height: 4
                        radius: Theme.radius.xxs
                        color: Theme.stroke.strong

                        Rectangle {
                            width: Math.min(IslandService.osdLevel, 1) * parent.width
                            height: parent.height
                            radius: Theme.radius.xxs
                            color: IslandService.osdMuted ? Theme.text.tertiary : Theme.accent
                            Behavior on width {
                                NumberAnimation {
                                    duration: Theme.motion.instant
                                    easing.type: Theme.motion.easeStandard
                                }
                            }
                        }
                    }
                    Text {
                        visible: pill.activity === "osd"
                        anchors.verticalCenter: parent.verticalCenter
                        text: IslandService.osdLabel !== "" ? IslandService.osdLabel : Math.round(IslandService.osdLevel * 100) + "%"
                        color: Theme.text.primary
                        font.pixelSize: Theme.type.body.size
                        font.family: Theme.font.ui
                    }

                    Rectangle {
                        visible: pill.activity === "recording"
                        anchors.verticalCenter: parent.verticalCenter
                        width: 8
                        height: 8
                        radius: Theme.radius.xs
                        color: Theme.danger

                        SequentialAnimation on opacity {
                            running: pill.activity === "recording"
                            loops: Animation.Infinite
                            NumberAnimation {
                                to: 0.3
                                duration: 800
                            }
                            NumberAnimation {
                                to: 1
                                duration: 800
                            }
                        }

                        TapHandler {
                            onTapped: pill.recDetails = !pill.recDetails
                        }
                        HoverHandler {
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                    Text {
                        visible: pill.activity === "recording" && !IslandService.musicAvailable
                        anchors.verticalCenter: parent.verticalCenter
                        text: StreamingService.isRecordingScreen ? "Recording" : "Screen shared"
                        color: Theme.danger
                        font.pixelSize: Theme.type.body.size
                        font.family: Theme.font.ui
                        font.weight: Font.Medium

                        TapHandler {
                            onTapped: pill.recDetails = !pill.recDetails
                        }
                        HoverHandler {
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }

                Column {
                    id: recArea
                    anchors.top: parent.top
                    anchors.topMargin: pill.compactHeight
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Theme.space.sm
                    opacity: pill.recDetails ? 1 : 0
                    visible: opacity > 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.motion.fast
                        }
                    }

                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: Theme.space.xs

                        Repeater {
                            model: StreamingService.screenAccessApps

                            Text {
                                required property string modelData
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData
                                color: Theme.text.secondary
                                font.pixelSize: Theme.type.body.size
                                font.family: Theme.font.ui
                            }
                        }

                        Rectangle {
                            visible: StreamingService.isRecordingScreen
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: stopLabel.implicitWidth + 24
                            height: 24
                            radius: Theme.radius.md
                            color: stopHover.hovered ? Theme.danger : "transparent"
                            border.width: 1
                            border.color: Theme.danger

                            Text {
                                id: stopLabel
                                anchors.centerIn: parent
                                text: "Stop"
                                color: stopHover.hovered ? Theme.dangerText : Theme.danger
                                font.pixelSize: Theme.type.body.size
                                font.family: Theme.font.ui
                                font.weight: Font.Medium
                            }

                            HoverHandler {
                                id: stopHover
                                cursorShape: Qt.PointingHandCursor
                            }
                            TapHandler {
                                onTapped: StreamingService.stopRecording()
                            }
                        }
                    }
                }

                Row {
                    id: notifContent
                    anchors.top: parent.top
                    anchors.topMargin: pill.inset
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 380 - pill.inset * 2
                    spacing: Theme.space.lg
                    opacity: pill.notif ? 1 : 0
                    visible: opacity > 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.motion.fast
                        }
                    }

                    ClippingRectangle {
                        width: 44
                        height: 44
                        radius: Theme.radius.md
                        color: Theme.colors.raised

                        CrossfadeImage {
                            anchors.fill: parent
                            source: IslandService.trackArtUrl || ""
                        }

                        Text {
                            anchors.centerIn: parent
                            text: PhosphorIcons.musicNoteSimple
                            font.family: Theme.font.icon
                            font.pixelSize: Theme.icon.lg
                            color: Theme.text.secondary
                            visible: IslandService.trackArtUrl === ""
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 44 - 12 - 28 - 12
                        spacing: Theme.space.xxs

                        Text {
                            width: parent.width
                            text: IslandService.trackTitle || ""
                            color: Theme.text.primary
                            font.pixelSize: Theme.type.body.size
                            font.family: Theme.font.ui
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }

                        Text {
                            width: parent.width
                            visible: (IslandService.trackArtist || "") !== ""
                            text: IslandService.trackArtist || ""
                            color: Theme.text.secondary
                            font.pixelSize: Theme.type.caption.size
                            font.family: Theme.font.ui
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }

                        HoverHandler {
                            cursorShape: Qt.PointingHandCursor
                        }
                    }

                    MediaControlButton {
                        anchors.verticalCenter: parent.verticalCenter
                        icon: PhosphorIcons.skipForward
                        onTapped: MediaControlService.next()
                    }
                }

                Column {
                    id: fullContent
                    anchors.top: parent.top
                    anchors.topMargin: pill.inset
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Theme.space.lg
                    opacity: pill.full ? 1 : 0
                    visible: opacity > 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.motion.fast
                        }
                    }

                    Item {
                        width: tabBar.implicitWidth
                        height: tabBar.implicitHeight

                        Rectangle {
                            id: tabHighlight

                            readonly property Item chip: tabRepeater.count > pill.tab ? tabRepeater.itemAt(pill.tab) : null

                            x: chip ? chip.x : 0
                            width: chip ? chip.width : 0
                            height: tabBar.implicitHeight
                            radius: Theme.radius.md
                            color: Theme.fill.selected

                            Behavior on x {
                                NumberAnimation {
                                    duration: Theme.motion.normal
                                    easing.type: Theme.motion.easeStandard
                                }
                            }
                            Behavior on width {
                                NumberAnimation {
                                    duration: Theme.motion.normal
                                    easing.type: Theme.motion.easeStandard
                                }
                            }
                        }

                        Row {
                            id: tabBar
                            spacing: Theme.space.sm

                            Repeater {
                                id: tabRepeater
                                model: ["Now Playing", "Calendar"]

                                delegate: Rectangle {
                                    id: tabChip

                                    required property string modelData
                                    required property int index

                                    readonly property bool active: pill.tab === tabChip.index

                                    width: tabLabel.implicitWidth + 24
                                    height: 28
                                    radius: Theme.radius.md
                                    color: tabChip.active ? Theme.withAlpha(Theme.fill.hover, 0) : tabHover.hovered ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: Theme.motion.fast
                                        }
                                    }

                                    Text {
                                        id: tabLabel
                                        anchors.centerIn: parent
                                        text: tabChip.modelData
                                        color: tabChip.active ? Theme.text.primary : Theme.text.secondary
                                        font.family: Theme.font.ui
                                        font.pixelSize: Theme.type.caption.size
                                        font.weight: Font.Medium

                                        Behavior on color {
                                            ColorAnimation {
                                                duration: Theme.motion.normal
                                            }
                                        }
                                    }

                                    HoverHandler {
                                        id: tabHover
                                        cursorShape: Qt.PointingHandCursor
                                    }
                                    TapHandler {
                                        onTapped: pill.tab = tabChip.index
                                    }
                                }
                            }
                        }
                    }

                    Row {
                        id: tabContent
                        spacing: Theme.space.lg

                        Item {
                            id: tabSlot

                            width: pill.tab === 1 ? calendarView.width : musicColumn.width
                            height: pill.tab === 1 ? calendarView.height : (IslandService.musicAvailable ? musicColumn.height : musicEmpty.height)

                            Behavior on width {
                                NumberAnimation {
                                    duration: Theme.motion.normal
                                    easing.type: Theme.motion.easeStandard
                                }
                            }
                            Behavior on height {
                                NumberAnimation {
                                    duration: Theme.motion.normal
                                    easing.type: Theme.motion.easeStandard
                                }
                            }

                            CalendarView {
                                id: calendarView
                                x: 16 * (1 - pill.tabProgress)
                                opacity: Math.max(0, pill.tabProgress * 2 - 1)
                                visible: opacity > 0
                            }

                            Column {
                                id: musicColumn

                                readonly property int artSize: 96

                                width: 460
                                x: -16 * pill.tabProgress
                                opacity: IslandService.musicAvailable ? Math.max(0, 1 - pill.tabProgress * 2) : 0
                                visible: opacity > 0
                                spacing: Theme.space.lg

                                Row {
                                    width: parent.width
                                    spacing: Theme.space.lg

                                    ClippingRectangle {
                                        width: musicColumn.artSize
                                        height: musicColumn.artSize
                                        radius: Theme.radius.md
                                        color: Theme.colors.raised

                                        CrossfadeImage {
                                            anchors.fill: parent
                                            source: IslandService.trackArtUrl || ""
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: PhosphorIcons.musicNoteSimple
                                            font.family: Theme.font.icon
                                            font.pixelSize: Theme.icon.xxl
                                            color: Theme.text.secondary
                                            visible: IslandService.trackArtUrl === ""
                                        }
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width - musicColumn.artSize - Theme.space.lg
                                        spacing: Theme.space.xs

                                        Text {
                                            width: parent.width
                                            text: IslandService.trackTitle
                                            color: Theme.text.primary
                                            font.pixelSize: Theme.type.display.size
                                            font.family: Theme.font.ui
                                            font.weight: Font.Medium
                                            elide: Text.ElideRight
                                            maximumLineCount: 1
                                        }

                                        Text {
                                            width: parent.width
                                            visible: (IslandService.trackArtist || "") !== ""
                                            text: IslandService.trackArtist || ""
                                            color: Theme.text.secondary
                                            font.pixelSize: Theme.type.body.size
                                            font.family: Theme.font.ui
                                            elide: Text.ElideRight
                                            maximumLineCount: 1
                                        }

                                        Text {
                                            width: parent.width
                                            visible: IslandService.albumName !== ""
                                            text: IslandService.albumName
                                            color: Theme.text.tertiary
                                            font.pixelSize: Theme.type.caption.size
                                            font.family: Theme.font.ui
                                            elide: Text.ElideRight
                                            maximumLineCount: 1
                                        }
                                    }
                                }

                                Column {
                                    width: parent.width
                                    spacing: Theme.space.xxs

                                    Timer {
                                        id: seekDebounce
                                        interval: 300
                                    }

                                    StyledSlider {
                                        id: seekSlider

                                        width: parent.width
                                        from: 0
                                        to: IslandService.duration > 0 ? IslandService.duration : 1
                                        boundValue: IslandService.position
                                        enabled: IslandService.canSeek

                                        holding: seekDebounce.running
                                        trackColor: Theme.stroke.strong
                                        accentColor: Theme.accent
                                        handleSize: 10
                                        onPressedChanged: {
                                            if (!pressed) {
                                                MediaControlService.seek(value);
                                                seekDebounce.start();
                                            }
                                        }
                                    }

                                    Item {
                                        width: parent.width
                                        height: elapsedLabel.implicitHeight

                                        Text {
                                            id: elapsedLabel
                                            anchors.left: parent.left
                                            text: overlay.formatTime(seekSlider.value)
                                            color: Theme.text.secondary
                                            font.pixelSize: Theme.type.caption.size
                                            font.family: Theme.font.ui
                                        }
                                        Text {
                                            anchors.right: parent.right
                                            text: overlay.formatTime(IslandService.duration)
                                            color: Theme.text.secondary
                                            font.pixelSize: Theme.type.caption.size
                                            font.family: Theme.font.ui
                                        }
                                    }
                                }

                                Row {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: Theme.space.lg

                                    MediaControlButton {
                                        anchors.verticalCenter: parent.verticalCenter
                                        icon: PhosphorIcons.skipBack
                                        onTapped: MediaControlService.previous()
                                    }

                                    MediaControlButton {
                                        anchors.verticalCenter: parent.verticalCenter
                                        icon: IslandService.isPlaying ? PhosphorIcons.pause : PhosphorIcons.play
                                        iconSize: 22
                                        filled: true
                                        onTapped: MediaControlService.playpause()
                                    }

                                    MediaControlButton {
                                        anchors.verticalCenter: parent.verticalCenter
                                        icon: PhosphorIcons.skipForward
                                        onTapped: MediaControlService.next()
                                    }
                                }
                            }

                            Item {
                                id: musicEmpty
                                width: musicColumn.width
                                height: musicColumn.implicitHeight
                                x: -16 * pill.tabProgress
                                opacity: IslandService.musicAvailable ? 0 : Math.max(0, 1 - pill.tabProgress * 2)
                                visible: opacity > 0

                                Column {
                                    anchors.centerIn: parent
                                    spacing: Theme.space.md

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: PhosphorIcons.musicNoteSimple
                                        color: Theme.text.secondary
                                        font.pixelSize: Theme.icon.xxl
                                        font.family: Theme.font.icon
                                    }

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "Nothing playing"
                                        color: Theme.text.secondary
                                        font.pixelSize: Theme.type.body.size
                                        font.family: Theme.font.ui
                                    }
                                }
                            }
                        }

                        Column {
                            id: quickControls
                            width: 56
                            spacing: Theme.space.md

                            ToggleRow {
                                style: "compact"
                                danger: true
                                glyph: AudioService.sourceMuted ? PhosphorIcons.microphoneSlash : PhosphorIcons.microphone
                                active: AudioService.sourceMuted
                                onToggled: AudioService.toggleSourceMute()
                            }

                            ToggleRow {
                                style: "compact"
                                label: "DND"
                                active: SettingsService.doNotDisturb
                                onToggled: SettingsService.doNotDisturb = !SettingsService.doNotDisturb
                            }

                            ToggleRow {
                                style: "compact"
                                glyph: SunsetService.active ? PhosphorIcons.moon : PhosphorIcons.sun
                                active: SunsetService.active
                                onToggled: SunsetService.toggle()
                            }
                        }
                    }
                }
            }
        }
    }
}
