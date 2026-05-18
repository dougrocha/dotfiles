pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import qs.Constants
import qs.Services

// On each Cider track change, drops a fluid blob from the centre of the top
// bar, splashes, and morphs into a card showing art + title + artist.
// Holds for 5 s then fades. Click-through overlay — never steals focus.
Variants {
    id: root
    model: Quickshell.screens

    delegate: PanelWindow {
        id: overlay

        required property var modelData
        screen: modelData

        color: "transparent"
        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: 140
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs.song-drop"
        mask: Region {}

        // ---------- Track state ----------
        property string trackTitle: ""
        property string trackArtist: ""
        property string trackArtUrl: ""
        property string lastShownKey: ""
        property real titleCascade: 0
        property real metaOpacity: 0

        Connections {
            target: CiderRpcService
            function onTrackChanged() {
                if (!CiderRpcService.trackTitle)
                    return;
                if (Visibilities.musicPanel)
                    return;
                const key = CiderRpcService.trackTitle + CiderRpcService.trackArtist;
                if (key === overlay.lastShownKey)
                    return;
                overlay.lastShownKey = key;
                overlay.titleCascade = 0;
                overlay.metaOpacity = 0;
                overlay.trackTitle = CiderRpcService.trackTitle;
                overlay.trackArtist = CiderRpcService.trackArtist || "";
                overlay.trackArtUrl = CiderRpcService.trackArtUrl || "";
                dropAnim.restart();
            }
        }

        Item {
            id: stage
            anchors.fill: parent

            readonly property real cardWidth: Math.min(340, parent.width - 40)
            readonly property real cardHeight: 64
            readonly property real cardY: Theme.topBarHeight + 12
            readonly property real centerX: width / 2
            readonly property real impactY: cardY + cardHeight / 2 - 8

            // ---- Pre-roll brightening ----
            Rectangle {
                id: preRoll
                width: 200
                height: Theme.topBarHeight
                radius: Theme.topBarHeight / 2
                x: stage.centerX - width / 2
                y: 0
                color: Colors.on_surface
                opacity: 0
                antialiasing: true
            }

            // ---- Falling drop ----
            Rectangle {
                id: drop
                property real cx: stage.centerX
                property real cy: Theme.topBarHeight
                property real size: 14
                property real stretch: 1.0

                width: size / Math.sqrt(stretch)
                height: size * stretch
                radius: Math.min(width, height) / 2
                x: cx - width / 2
                y: cy - height / 2
                color: Colors.primary
                opacity: 0
                antialiasing: true
            }

            Rectangle {
                id: tail
                property real cx: stage.centerX
                property real cy: Theme.topBarHeight
                width: 6
                height: 6
                radius: 3
                x: cx - width / 2
                y: cy - height / 2
                color: Colors.primary
                opacity: 0
            }

            // ---- Splash droplets ----
            Rectangle {
                id: splash0
                property real travel: 0
                readonly property real angle: -2.5
                width: 5
                height: 5
                radius: 2.5
                x: stage.centerX + Math.cos(angle) * travel - width / 2
                y: stage.impactY + Math.sin(angle) * travel - height / 2
                color: Colors.primary
                opacity: 0
            }
            Rectangle {
                id: splash1
                property real travel: 0
                readonly property real angle: -2.0
                width: 5
                height: 5
                radius: 2.5
                x: stage.centerX + Math.cos(angle) * travel - width / 2
                y: stage.impactY + Math.sin(angle) * travel - height / 2
                color: Colors.primary
                opacity: 0
            }
            Rectangle {
                id: splash2
                property real travel: 0
                readonly property real angle: -1.14
                width: 5
                height: 5
                radius: 2.5
                x: stage.centerX + Math.cos(angle) * travel - width / 2
                y: stage.impactY + Math.sin(angle) * travel - height / 2
                color: Colors.primary
                opacity: 0
            }
            Rectangle {
                id: splash3
                property real travel: 0
                readonly property real angle: -0.64
                width: 5
                height: 5
                radius: 2.5
                x: stage.centerX + Math.cos(angle) * travel - width / 2
                y: stage.impactY + Math.sin(angle) * travel - height / 2
                color: Colors.primary
                opacity: 0
            }

            // ---- Settled card ----
            Rectangle {
                id: card
                width: stage.cardWidth
                height: stage.cardHeight
                x: stage.centerX - width / 2
                y: stage.cardY
                radius: 16
                color: Colors.surface_container_low
                border.width: 1
                border.color: Colors.outline_variant
                opacity: 0
                scale: 0
                transformOrigin: Item.Top
                antialiasing: true
                layer.enabled: true

                // Blurred album art background (mirrors MusicPanel)
                Image {
                    id: bgArt
                    anchors.fill: parent
                    source: overlay.trackArtUrl
                    fillMode: Image.PreserveAspectCrop
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        blurEnabled: true
                        blurMax: 48
                        blur: 1
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: Qt.rgba(Colors.scrim.r, Colors.scrim.g, Colors.scrim.b, 0.55)
                    visible: bgArt.status === Image.Ready
                }

                // Mask to enforce rounded corners over the blurred layer
                Rectangle {
                    id: cardMask
                    width: card.width
                    height: card.height
                    radius: card.radius
                    visible: false
                }

                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: ShaderEffectSource {
                        sourceItem: cardMask
                        hideSource: true
                        live: true
                    }
                }

                // Content row: album art thumbnail + text
                Row {
                    id: contentRow
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 12
                    opacity: 0

                    // Album art thumbnail
                    Rectangle {
                        id: artContainer
                        width: 44
                        height: 44
                        radius: 8
                        color: Colors.surface_container
                        anchors.verticalCenter: parent.verticalCenter
                        clip: true

                        Image {
                            anchors.fill: parent
                            source: overlay.trackArtUrl
                            fillMode: Image.PreserveAspectCrop
                        }

                        Text {
                            anchors.centerIn: parent
                            text: PhosphorIcons.musicNoteSimple
                            font.family: Fonts.phosphorFont
                            font.pixelSize: 20
                            color: Colors.on_surface_variant
                            visible: overlay.trackArtUrl === ""
                        }
                    }

                    // Title + artist
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 3
                        width: stage.cardWidth - 44 - 10 - 12 - 10

                        // Title with per-glyph cascade
                        Item {
                            id: titleClip
                            height: 18
                            width: parent.width
                            clip: true

                            Row {
                                id: titleRow
                                spacing: 0
                                anchors.verticalCenter: parent.verticalCenter

                                Repeater {
                                    model: overlay.trackTitle.split("")
                                    delegate: Text {
                                        required property string modelData
                                        required property int index
                                        text: modelData === " " ? " " : modelData
                                        color: Colors.on_surface
                                        font.family: Fonts.font
                                        font.pixelSize: 13
                                        font.weight: Font.Bold
                                        opacity: Math.max(0, Math.min(1, overlay.titleCascade - index))
                                    }
                                }
                            }
                        }

                        Text {
                            text: overlay.trackArtist
                            visible: overlay.trackArtist.length > 0
                            color: Colors.on_surface_variant
                            font.family: Fonts.font
                            font.pixelSize: 11
                            elide: Text.ElideRight
                            width: parent.width
                            opacity: overlay.metaOpacity
                        }
                    }
                }
            }

            // ---- Master timeline ----
            SequentialAnimation {
                id: dropAnim

                ScriptAction {
                    script: {
                        drop.cy = Theme.topBarHeight - 4;
                        drop.size = 14;
                        drop.stretch = 1.0;
                        drop.opacity = 0;
                        tail.cy = Theme.topBarHeight - 4;
                        tail.opacity = 0;
                        card.scale = 0;
                        card.opacity = 0;
                        contentRow.opacity = 0;
                        preRoll.opacity = 0;
                        overlay.titleCascade = 0;
                        overlay.metaOpacity = 0;
                        splash0.travel = 0;
                        splash0.opacity = 0;
                        splash1.travel = 0;
                        splash1.opacity = 0;
                        splash2.travel = 0;
                        splash2.opacity = 0;
                        splash3.travel = 0;
                        splash3.opacity = 0;
                    }
                }

                // 0) Pre-roll
                SequentialAnimation {
                    NumberAnimation {
                        target: preRoll
                        property: "opacity"
                        from: 0
                        to: 0.04
                        duration: 60
                        easing.type: Easing.OutQuad
                    }
                    PauseAnimation {
                        duration: 20
                    }
                }

                // 1) Fall + teardrop stretch
                ParallelAnimation {
                    ScriptAction {
                        script: drop.opacity = 1
                    }
                    NumberAnimation {
                        target: preRoll
                        property: "opacity"
                        to: 0
                        duration: 240
                        easing.type: Easing.InQuad
                    }
                    NumberAnimation {
                        target: drop
                        property: "cy"
                        from: Theme.topBarHeight - 4
                        to: stage.cardY + stage.cardHeight / 2 - 10
                        duration: 440
                        easing.type: Easing.InQuad
                    }
                    NumberAnimation {
                        target: drop
                        property: "stretch"
                        from: 1.0
                        to: 2.6
                        duration: 440
                        easing.type: Easing.InQuad
                    }
                    SequentialAnimation {
                        PauseAnimation {
                            duration: 80
                        }
                        ParallelAnimation {
                            NumberAnimation {
                                target: tail
                                property: "opacity"
                                from: 0
                                to: 1
                                duration: 100
                            }
                            NumberAnimation {
                                target: tail
                                property: "cy"
                                from: Theme.topBarHeight - 4
                                to: stage.cardY + stage.cardHeight / 2 - 28
                                duration: 360
                                easing.type: Easing.InQuad
                            }
                        }
                    }
                }

                // 2) Squash on impact, launch splash
                ParallelAnimation {
                    NumberAnimation {
                        target: drop
                        property: "stretch"
                        to: 0.45
                        duration: 110
                        easing.type: Easing.OutQuad
                    }
                    NumberAnimation {
                        target: drop
                        property: "size"
                        to: 30
                        duration: 110
                        easing.type: Easing.OutQuad
                    }
                    NumberAnimation {
                        target: tail
                        property: "cy"
                        to: stage.cardY + stage.cardHeight / 2 - 6
                        duration: 110
                    }
                    NumberAnimation {
                        target: tail
                        property: "opacity"
                        to: 0
                        duration: 110
                    }
                    ScriptAction {
                        script: {
                            splash0.opacity = 1;
                            splash1.opacity = 1;
                            splash2.opacity = 1;
                            splash3.opacity = 1;
                        }
                    }
                }

                // 3) Morph: drop dissolves, splash flies out, card scales in
                ParallelAnimation {
                    NumberAnimation {
                        target: drop
                        property: "opacity"
                        to: 0
                        duration: 220
                    }
                    NumberAnimation {
                        target: drop
                        property: "size"
                        to: 60
                        duration: 220
                    }

                    NumberAnimation {
                        target: splash0
                        property: "travel"
                        from: 0
                        to: 36
                        duration: 360
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: splash1
                        property: "travel"
                        from: 0
                        to: 28
                        duration: 340
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: splash2
                        property: "travel"
                        from: 0
                        to: 30
                        duration: 360
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: splash3
                        property: "travel"
                        from: 0
                        to: 38
                        duration: 380
                        easing.type: Easing.OutCubic
                    }

                    SequentialAnimation {
                        PauseAnimation {
                            duration: 220
                        }
                        ParallelAnimation {
                            NumberAnimation {
                                target: splash0
                                property: "opacity"
                                to: 0
                                duration: 160
                            }
                            NumberAnimation {
                                target: splash1
                                property: "opacity"
                                to: 0
                                duration: 160
                            }
                            NumberAnimation {
                                target: splash2
                                property: "opacity"
                                to: 0
                                duration: 160
                            }
                            NumberAnimation {
                                target: splash3
                                property: "opacity"
                                to: 0
                                duration: 160
                            }
                        }
                    }

                    SequentialAnimation {
                        PauseAnimation {
                            duration: 60
                        }
                        ParallelAnimation {
                            NumberAnimation {
                                target: card
                                property: "scale"
                                from: 0
                                to: 1
                                duration: 360
                                easing.type: Easing.OutBack
                                easing.overshoot: 1.6
                            }
                            NumberAnimation {
                                target: card
                                property: "opacity"
                                from: 0
                                to: 1
                                duration: 240
                            }
                        }
                    }
                }

                // 4) Reveal content: per-glyph title cascade + artist fade
                ScriptAction {
                    script: contentRow.opacity = 1
                }
                ParallelAnimation {
                    NumberAnimation {
                        target: overlay
                        property: "titleCascade"
                        from: 0
                        to: overlay.trackTitle.length + 2
                        duration: (overlay.trackTitle.length + 2) * 8
                    }
                    NumberAnimation {
                        target: overlay
                        property: "metaOpacity"
                        from: 0
                        to: 1
                        duration: 220
                    }
                }

                // 5) Hold
                PauseAnimation {
                    duration: 5000
                }

                // 6) Exit: content fades, card inhales upward
                SequentialAnimation {
                    NumberAnimation {
                        target: contentRow
                        property: "opacity"
                        to: 0
                        duration: 180
                        easing.type: Easing.InCubic
                    }
                    ParallelAnimation {
                        NumberAnimation {
                            target: card
                            property: "scale"
                            to: 0
                            duration: 520
                            easing.type: Easing.InBack
                            easing.overshoot: 1.4
                        }
                        NumberAnimation {
                            target: card
                            property: "opacity"
                            to: 0
                            duration: 440
                            easing.type: Easing.InCubic
                        }
                    }
                }
            }
        }
    }
}
