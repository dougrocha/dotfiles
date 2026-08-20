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

// Dynamic-island pill in the bar's center gap: shows the highest-priority
// activity (osd > recording > music > idle), expands on hover, and morphs into
// the full player on click. Everything outside the pill is click-through.
Variants {
    id: root
    model: Theme.primaryScreens

    delegate: PanelWindow {
        id: overlay

        required property var modelData
        screen: modelData

        // Right-clicking the clock cycles these; an unknown stored value restarts at the first.
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
        // Fixed: resizing the surface mid-animation tears.
        implicitHeight: 560
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs.island"

        // Transients still drop over fullscreen, where the bar's hover strip is unreachable.
        readonly property bool revealed: Visibilities.barRevealed || IslandService.osdActive || IslandService.songNotif

        // Bound to geometry, not the item: the pill resizes constantly and a region bound to the item wouldn't track.
        mask: Region {
            x: pill.x
            y: slide.y + pill.y
            width: overlay.revealed ? pill.width : 0
            height: overlay.revealed ? pill.height : 0
        }

        // Click-away collapses the full player, matching popup behavior.
        HyprlandFocusGrab {
            windows: [overlay]
            active: overlay.visible && Visibilities.musicPanel
            onCleared: Visibilities.musicPanel = false
        }

        // Slides with the bar, and far enough that no state peeks past the top edge.
        Item {
            id: slide
            width: parent.width
            height: parent.height
            y: overlay.revealed ? 0 : -(pill.y + pill.height)

            Behavior on y {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            Rectangle {
                id: pill

                readonly property string activity: IslandService.activity
                readonly property bool full: Visibilities.musicPanel
                readonly property bool notif: !full && IslandService.songNotif && !IslandService.osdActive
                property bool recDetails: false
                readonly property int compactHeight: Theme.topBarHeight - 8

                // Where the pill is heading; +28 is the 14px inset top and bottom.
                readonly property int targetHeight: full ? fullContent.implicitHeight + 28 : notif ? notifContent.implicitHeight + 28 : recDetails ? compactHeight + recArea.implicitHeight + 12 : compactHeight

                // Which tab the expanded panel shows: 0 = now playing,
                // 1 = calendar. Remembered between opens.
                property int tab: 0

                // Drives the tab swap: the panes derive opacity from this, so
                // one is fully out before the other starts.
                property real tabProgress: tab

                Behavior on tabProgress {
                    NumberAnimation {
                        duration: Theme.animations.normal
                        easing.type: Easing.InOutQuad
                    }
                }

                onActivityChanged: recDetails = false

                // The calendar keeps its month; send it back to today when it reappears.
                onTabChanged: if (tab === 1)
                    calendarView.reset()
                onFullChanged: if (full && tab === 1)
                    calendarView.reset()

                anchors.horizontalCenter: parent.horizontalCenter
                y: 4
                // The calendar is narrower than the player, so the pill tightens
                // around it rather than leaving the tab swimming in dead space.
                width: full ? (tab === 0 ? 560 : 420) : notif ? 380 : compactRow.implicitWidth + 28
                height: targetHeight
                radius: full ? 24 : notif ? 20 : recDetails ? 18 : compactHeight / 2
                color: Colors.surface
                clip: true

                // Open (not toggle): a click over a child fires both handlers, and two toggles cancel.
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

                // Not a spring: the pill clips, so overshoot squeezes its contents.
                Behavior on width {
                    NumberAnimation {
                        duration: Theme.animations.normal
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on height {
                    NumberAnimation {
                        duration: Theme.animations.normal
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on radius {
                    NumberAnimation {
                        duration: Theme.animations.fast
                        easing.type: Easing.OutCubic
                    }
                }

                // Blurred album art fills the pill in full-player mode.
                ClippingRectangle {
                    anchors.fill: parent
                    radius: pill.radius
                    color: "transparent"
                    opacity: pill.notif ? 1 : pill.full ? Math.max(0, 1 - pill.tabProgress * 2) : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.animations.fast
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
                        color: Qt.rgba(Colors.scrim.r, Colors.scrim.g, Colors.scrim.b, 0.6)
                        visible: backgroundArt.ready
                    }
                }

                Row {
                    id: compactRow
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: (pill.compactHeight - height) / 2
                    height: 20
                    spacing: 8
                    opacity: (pill.full || pill.notif) ? 0 : 1
                    visible: opacity > 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.animations.fast
                        }
                    }

                    // Always-on clock; the pill's own handler opens the full player.
                    ClockWidget {
                        anchors.verticalCenter: parent.verticalCenter
                        format: SettingsService.clockFormat
                        color: clockHover.hovered ? Colors.on_surface : Colors.on_surface_variant
                        font.pixelSize: Fonts.p
                        font.family: Fonts.font
                        font.weight: Font.Light
                        font.letterSpacing: 1

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.animations.fast
                            }
                        }

                        HoverHandler {
                            id: clockHover
                            cursorShape: Qt.PointingHandCursor
                        }

                        // Left-click falls through to the pill, which opens the
                        // full player; only the right button is claimed here.
                        TapHandler {
                            acceptedButtons: Qt.RightButton
                            onTapped: overlay.cycleClockFormat()
                        }
                    }

                    // Divider between the clock and whatever activity is showing.
                    Rectangle {
                        visible: pill.activity !== "idle" || AudioService.micInUse
                        anchors.verticalCenter: parent.verticalCenter
                        width: 1
                        height: 14
                        color: Colors.outline_variant
                    }

                    // Music: track text (shown alongside recording too, mac-style)
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
                            color: Colors.secondary
                            font.pixelSize: Fonts.p
                            font.family: Fonts.font
                            font.bold: true

                            readonly property real overflow: Math.max(0, implicitWidth - musicTextClip.width)

                            // No point scrolling while the row is swapped out or the island is tucked away.
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
                                    easing.type: Easing.InOutQuad
                                }
                                PauseAnimation {
                                    duration: 2000
                                }
                                NumberAnimation {
                                    from: -musicText.overflow
                                    to: 0
                                    duration: musicText.overflow * 40
                                    easing.type: Easing.InOutQuad
                                }
                            }
                        }

                        HoverHandler {
                            cursorShape: Qt.PointingHandCursor
                        }
                    }

                    // Someone is listening. Sits outside the activity chain, so it can
                    // show next to music, a recording, or nothing at all.
                    Rectangle {
                        visible: AudioService.micInUse
                        anchors.verticalCenter: parent.verticalCenter
                        width: 8
                        height: 8
                        radius: 4
                        color: Colors.micActive
                    }

                    // OSD flash: icon + level bar + readout
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
                        color: IslandService.osdMuted ? Colors.on_surface_variant : Colors.primary
                        font.pixelSize: Fonts.h5
                        font.family: Fonts.phosphorFont
                    }
                    Rectangle {
                        visible: pill.activity === "osd"
                        anchors.verticalCenter: parent.verticalCenter
                        width: 120
                        height: 4
                        radius: 2
                        color: Colors.outline_variant

                        Rectangle {
                            width: Math.min(IslandService.osdLevel, 1) * parent.width
                            height: parent.height
                            radius: 2
                            color: IslandService.osdMuted ? Colors.outline : Colors.primary
                            Behavior on width {
                                NumberAnimation {
                                    duration: 80
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }
                    Text {
                        visible: pill.activity === "osd"
                        anchors.verticalCenter: parent.verticalCenter
                        text: IslandService.osdLabel !== "" ? IslandService.osdLabel : Math.round(IslandService.osdLevel * 100) + "%"
                        color: Colors.on_surface
                        font.pixelSize: Fonts.small
                        font.family: Fonts.font
                    }

                    // Recording: pulsing dot + label
                    Rectangle {
                        visible: pill.activity === "recording"
                        anchors.verticalCenter: parent.verticalCenter
                        width: 8
                        height: 8
                        radius: 4
                        color: Colors.error

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
                        color: Colors.error
                        font.pixelSize: Fonts.small
                        font.family: Fonts.font
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
                    spacing: 6
                    opacity: pill.recDetails ? 1 : 0
                    visible: opacity > 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.animations.fast
                        }
                    }

                    // Accessing apps + stop
                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 4

                        Repeater {
                            model: StreamingService.screenAccessApps

                            Text {
                                required property string modelData
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData
                                color: Colors.on_surface_variant
                                font.pixelSize: Fonts.small
                                font.family: Fonts.font
                            }
                        }

                        Rectangle {
                            visible: StreamingService.isRecordingScreen
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: stopLabel.implicitWidth + 24
                            height: 24
                            radius: Theme.blockRadius
                            color: stopHover.hovered ? Colors.error : "transparent"
                            border.width: 1
                            border.color: Colors.error

                            Text {
                                id: stopLabel
                                anchors.centerIn: parent
                                text: "Stop"
                                color: stopHover.hovered ? Colors.on_primary : Colors.error
                                font.pixelSize: Fonts.small
                                font.family: Fonts.font
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
                    anchors.topMargin: 14
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 380 - 24
                    spacing: 12
                    opacity: pill.notif ? 1 : 0
                    visible: opacity > 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.animations.fast
                        }
                    }

                    ClippingRectangle {
                        width: 44
                        height: 44
                        radius: Theme.blockRadius
                        color: Colors.surface_container

                        CrossfadeImage {
                            anchors.fill: parent
                            source: IslandService.trackArtUrl || ""
                        }

                        Text {
                            anchors.centerIn: parent
                            text: Icons.musicNote2
                            font.family: Fonts.iconFont
                            font.pixelSize: 20
                            color: Colors.on_surface_variant
                            visible: IslandService.trackArtUrl === ""
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 44 - 12 - 28 - 12
                        spacing: 3

                        Text {
                            width: parent.width
                            text: IslandService.trackTitle || ""
                            color: Colors.on_surface
                            font.pixelSize: 13
                            font.family: Fonts.font
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }

                        Text {
                            width: parent.width
                            visible: (IslandService.trackArtist || "") !== ""
                            text: IslandService.trackArtist || ""
                            color: Colors.on_surface_variant
                            font.pixelSize: Fonts.caption
                            font.family: Fonts.font
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }

                        HoverHandler {
                            cursorShape: Qt.PointingHandCursor
                        }
                    }

                    MediaControlButton {
                        anchors.verticalCenter: parent.verticalCenter
                        icon: Icons.skipNext
                        iconSize: 24
                        onTapped: MediaControlService.next()
                    }
                }

                // Tab bar over swappable content, with quick controls beside whichever tab is up.
                Column {
                    id: fullContent
                    anchors.top: parent.top
                    anchors.topMargin: 14
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 12
                    opacity: pill.full ? 1 : 0
                    visible: opacity > 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.animations.fast
                        }
                    }

                    Item {
                        width: tabBar.implicitWidth
                        height: tabBar.implicitHeight

                        Rectangle {
                            id: tabHighlight

                            readonly property Item chip: tabBar.children[pill.tab]

                            x: chip ? chip.x : 0
                            width: chip ? chip.width : 0
                            height: tabBar.implicitHeight
                            radius: Theme.blockRadius
                            color: Qt.rgba(Colors.on_surface.r, Colors.on_surface.g, Colors.on_surface.b, 0.18)

                            Behavior on x {
                                NumberAnimation {
                                    duration: Theme.animations.normal
                                    easing.type: Easing.OutCubic
                                }
                            }
                            Behavior on width {
                                NumberAnimation {
                                    duration: Theme.animations.normal
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }

                        Row {
                            id: tabBar
                            spacing: 6

                            Repeater {
                                model: ["Now Playing", "Calendar"]

                                delegate: Rectangle {
                                    id: tabChip

                                    required property string modelData
                                    required property int index

                                    readonly property bool active: pill.tab === tabChip.index

                                    width: tabLabel.implicitWidth + 24
                                    height: 28
                                    radius: Theme.blockRadius
                                    color: tabChip.active ? "transparent" : tabHover.hovered ? Qt.rgba(Colors.on_surface.r, Colors.on_surface.g, Colors.on_surface.b, 0.08) : "transparent"

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: Theme.animations.fast
                                        }
                                    }

                                    Text {
                                        id: tabLabel
                                        anchors.centerIn: parent
                                        text: tabChip.modelData
                                        color: tabChip.active ? Colors.on_surface : Colors.on_surface_variant
                                        font.family: Fonts.font
                                        font.pixelSize: Fonts.caption
                                        font.weight: Font.DemiBold

                                        Behavior on color {
                                            ColorAnimation {
                                                duration: Theme.animations.normal
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
                        spacing: 14

                        // Stacked rather than side by side so the tabs can cross-fade.
                        Item {
                            id: tabSlot

                            width: pill.tab === 1 ? calendarView.width : musicColumn.width
                            height: pill.tab === 1 ? calendarView.height : (IslandService.musicAvailable ? musicColumn.height : musicEmpty.height)

                            // Same curve as the pill, or the centred content
                            // snaps across while the pill is still travelling.
                            Behavior on width {
                                NumberAnimation {
                                    duration: Theme.animations.normal
                                    easing.type: Easing.OutCubic
                                }
                            }
                            Behavior on height {
                                NumberAnimation {
                                    duration: Theme.animations.normal
                                    easing.type: Easing.OutCubic
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
                                width: 462
                                x: -16 * pill.tabProgress
                                opacity: IslandService.musicAvailable ? Math.max(0, 1 - pill.tabProgress * 2) : 0
                                visible: opacity > 0
                                spacing: 6

                                // Top row: art + title/artist
                                Row {
                                    width: parent.width
                                    spacing: 14

                                    ClippingRectangle {
                                        width: 72
                                        height: 72
                                        radius: Theme.blockRadius
                                        color: Colors.surface_container

                                        CrossfadeImage {
                                            anchors.fill: parent
                                            source: IslandService.trackArtUrl || ""
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: Icons.musicNote2
                                            font.family: Fonts.iconFont
                                            font.pixelSize: 28
                                            color: Colors.on_surface_variant
                                            visible: IslandService.trackArtUrl === ""
                                        }
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width - 72 - 14
                                        spacing: 3

                                        Text {
                                            width: parent.width
                                            text: IslandService.trackTitle
                                            color: Colors.on_surface
                                            font.pixelSize: 15
                                            font.family: Fonts.font
                                            font.weight: Font.Bold
                                            elide: Text.ElideRight
                                            maximumLineCount: 1
                                        }

                                        Text {
                                            width: parent.width
                                            visible: (IslandService.trackArtist || "") !== ""
                                            text: IslandService.trackArtist || ""
                                            color: Colors.on_surface_variant
                                            font.pixelSize: 12
                                            font.family: Fonts.font
                                            elide: Text.ElideRight
                                            maximumLineCount: 1
                                        }

                                        Text {
                                            width: parent.width
                                            visible: (CiderRpcService.albumName || "") !== ""
                                            text: CiderRpcService.albumName || ""
                                            color: Colors.on_surface_variant
                                            font.pixelSize: Fonts.caption
                                            font.family: Fonts.font
                                            elide: Text.ElideRight
                                            maximumLineCount: 1
                                        }
                                    }
                                }

                                // Seek bar + timestamps
                                Column {
                                    width: parent.width
                                    spacing: 2

                                    Timer {
                                        id: seekDebounce
                                        interval: 300
                                    }

                                    StyledSlider {
                                        id: seekSlider

                                        width: parent.width
                                        from: 0
                                        to: CiderRpcService.duration > 0 ? CiderRpcService.duration : 1
                                        boundValue: CiderRpcService.position
                                        // Cider keeps pushing position mid-seek, so the bar stays ours until the debounce clears.
                                        holding: seekDebounce.running
                                        trackColor: Qt.rgba(Colors.on_surface_variant.r, Colors.on_surface_variant.g, Colors.on_surface_variant.b, 0.3)
                                        accentColor: Colors.on_surface
                                        pressedColor: Colors.on_surface
                                        handleSize: 10
                                        onPressedChanged: {
                                            if (!pressed) {
                                                CiderRpcService.seek(value);
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
                                            color: Colors.on_surface_variant
                                            font.pixelSize: Fonts.caption
                                            font.family: Fonts.font
                                        }
                                        Text {
                                            anchors.right: parent.right
                                            text: overlay.formatTime(CiderRpcService.duration)
                                            color: Colors.on_surface_variant
                                            font.pixelSize: Fonts.caption
                                            font.family: Fonts.font
                                        }
                                    }
                                }

                                // Controls
                                Row {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 20

                                    MediaControlButton {
                                        anchors.verticalCenter: parent.verticalCenter
                                        icon: Icons.skipPrevious
                                        onTapped: MediaControlService.previous()
                                    }

                                    MediaControlButton {
                                        anchors.verticalCenter: parent.verticalCenter
                                        icon: CiderRpcService.isPlaying ? Icons.pause : Icons.play
                                        iconSize: 32
                                        filled: true
                                        onTapped: MediaControlService.playpause()
                                    }

                                    MediaControlButton {
                                        anchors.verticalCenter: parent.verticalCenter
                                        icon: Icons.skipNext
                                        onTapped: MediaControlService.next()
                                    }
                                }
                            }

                            // Cider offline or nothing queued. Same width as the player so the pill doesn't resize.
                            Item {
                                id: musicEmpty
                                width: musicColumn.width
                                height: 160
                                x: -16 * pill.tabProgress
                                opacity: IslandService.musicAvailable ? 0 : Math.max(0, 1 - pill.tabProgress * 2)
                                visible: opacity > 0

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 8

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: Icons.musicNote2
                                        color: Colors.on_surface_variant
                                        font.pixelSize: 40
                                        font.family: Fonts.iconFont
                                    }

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "Nothing playing"
                                        color: Colors.on_surface_variant
                                        font.pixelSize: Fonts.p
                                        font.family: Fonts.font
                                    }
                                }
                            }
                        }

                        // Mic, DND, night light; top-aligned so they don't float beside the taller calendar.
                        Column {
                            id: quickControls
                            width: 56
                            spacing: 8

                            Rectangle {
                                width: 56
                                height: 40
                                radius: 12
                                color: AudioService.sourceMuted ? Colors.error_container : Qt.rgba(Colors.on_surface.r, Colors.on_surface.g, Colors.on_surface.b, 0.15)

                                Text {
                                    anchors.centerIn: parent
                                    text: AudioService.sourceMuted ? Icons.micOff : Icons.mic
                                    color: AudioService.sourceMuted ? Colors.on_error_container : Colors.on_surface
                                    font.pixelSize: Fonts.h4
                                    font.family: Fonts.iconFont
                                }
                                HoverHandler {
                                    cursorShape: Qt.PointingHandCursor
                                }
                                TapHandler {
                                    onTapped: AudioService.toggleSourceMute()
                                }
                            }

                            Rectangle {
                                width: 56
                                height: 40
                                radius: 12
                                color: SettingsService.doNotDisturb ? Colors.primary_container : Qt.rgba(Colors.on_surface.r, Colors.on_surface.g, Colors.on_surface.b, 0.15)

                                Text {
                                    anchors.centerIn: parent
                                    text: "DND"
                                    color: SettingsService.doNotDisturb ? Colors.on_primary_container : Colors.on_surface
                                    font.pixelSize: Fonts.caption
                                    font.family: Fonts.font
                                    font.weight: Font.Bold
                                }
                                HoverHandler {
                                    cursorShape: Qt.PointingHandCursor
                                }
                                TapHandler {
                                    onTapped: SettingsService.doNotDisturb = !SettingsService.doNotDisturb
                                }
                            }

                            Rectangle {
                                width: 56
                                height: 40
                                radius: 12
                                color: SunsetService.active ? Colors.tertiary_container : Qt.rgba(Colors.on_surface.r, Colors.on_surface.g, Colors.on_surface.b, 0.15)

                                Text {
                                    anchors.centerIn: parent
                                    text: SunsetService.active ? Icons.nightlight : Icons.wbSunny
                                    color: SunsetService.active ? Colors.on_tertiary_container : Colors.on_surface
                                    font.pixelSize: Fonts.h4
                                    font.family: Fonts.iconFont
                                }
                                HoverHandler {
                                    cursorShape: Qt.PointingHandCursor
                                }
                                TapHandler {
                                    onTapped: SunsetService.toggle()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
