pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Constants
import qs.Services

Rectangle {
    id: toolbar

    required property real outputX
    required property real outputY
    required property real outputWidth
    required property real outputHeight
    readonly property bool counting: ScreenshotSession.counting
    readonly property point placed: ScreenshotSession.toolbarPosition(width, height)

    implicitWidth: (counting ? countdownRow.implicitWidth : toolbarRow.implicitWidth) + 16
    implicitHeight: 52
    x: outputX + placed.x
    y: outputY + placed.y
    radius: Theme.radius.lg
    color: Theme.colors.surface
    border.width: 1
    border.color: Theme.stroke.hairline

    SizeMotion on implicitWidth {}

    layer.enabled: true
    layer.effect: null

    HoverHandler {
        blocking: true
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
        drag.target: toolbar
        drag.minimumX: toolbar.outputX
        drag.maximumX: toolbar.outputX + toolbar.outputWidth - toolbar.width
        drag.minimumY: toolbar.outputY
        drag.maximumY: toolbar.outputY + toolbar.outputHeight - toolbar.height
        onReleased: ScreenshotSession.placeToolbar(toolbar.x - toolbar.outputX, toolbar.y - toolbar.outputY)
    }

    RowLayout {
        id: toolbarRow

        anchors.centerIn: parent
        spacing: Theme.space.xxs
        visible: !toolbar.counting

        Item {
            implicitWidth: 24
            implicitHeight: 24
            Layout.rightMargin: 1

            Text {
                anchors.centerIn: parent
                text: PhosphorIcons.xCircle
                color: Theme.text.tertiary
                font.pixelSize: Theme.icon.lg
                font.family: Theme.font.iconFill
            }

            HoverHandler {
                cursorShape: Qt.PointingHandCursor
            }
            TapHandler {
                onTapped: ScreenshotSession.dismiss()
            }
        }

        Repeater {
            model: ScreenshotSession.modes

            delegate: ModeButton {}
        }

        ToolbarDivider {}

        Rectangle {
            implicitWidth: optionsLabel.implicitWidth + 16
            implicitHeight: 36
            radius: Theme.radius.md
            color: ScreenshotSession.optionsOpen || optionsHover.hovered ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

            Behavior on color {
                ColorAnimation {
                    duration: Theme.motion.fast
                }
            }

            Row {
                id: optionsLabel

                anchors.centerIn: parent
                spacing: Theme.space.xs

                Text {
                    text: "Options"
                    color: Theme.text.primary
                    font.pixelSize: Theme.type.body.size
                    font.family: Theme.font.ui
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: PhosphorIcons.caretDown
                    color: Theme.text.secondary
                    font.pixelSize: Theme.icon.xs
                    font.family: Theme.font.icon
                    anchors.verticalCenter: parent.verticalCenter
                    rotation: ScreenshotSession.optionsOpen ? 180 : 0

                    Behavior on rotation {
                        NumberAnimation {
                            duration: Theme.motion.fast
                        }
                    }
                }
            }

            HoverHandler {
                id: optionsHover

                cursorShape: Qt.PointingHandCursor
            }
            TapHandler {
                onTapped: ScreenshotSession.toggleOptions()
            }
        }

        Rectangle {
            implicitWidth: captureLabel.implicitWidth + 22
            implicitHeight: 36
            radius: Theme.radius.md
            opacity: ScreenshotSession.canCapture ? 1.0 : 0.45
            color: captureHover.hovered && captureHover.enabled ? Qt.lighter(Theme.accent, 1.1) : Theme.accent
            Layout.leftMargin: 3

            Behavior on color {
                ColorAnimation {
                    duration: Theme.motion.fast
                }
            }

            Text {
                id: captureLabel

                anchors.centerIn: parent
                text: "Capture"
                color: Theme.accentText
                font.pixelSize: Theme.type.body.size
                font.weight: Theme.type.title.weight
                font.family: Theme.font.ui
            }

            HoverHandler {
                id: captureHover

                enabled: ScreenshotSession.canCapture
                cursorShape: Qt.PointingHandCursor
            }
            TapHandler {
                enabled: ScreenshotSession.canCapture
                onTapped: ScreenshotSession.capture()
            }
        }
    }

    RowLayout {
        id: countdownRow

        anchors.centerIn: parent
        spacing: Theme.space.md
        visible: toolbar.counting

        Rectangle {
            implicitWidth: cancelLabel.implicitWidth + 16
            implicitHeight: 32
            radius: Theme.radius.sm
            color: cancelHover.hovered ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

            Text {
                id: cancelLabel

                anchors.centerIn: parent
                text: "Cancel"
                color: Theme.text.primary
                font.pixelSize: Theme.type.body.size
                font.family: Theme.font.ui
            }

            HoverHandler {
                id: cancelHover

                cursorShape: Qt.PointingHandCursor
            }
            TapHandler {
                onTapped: ScreenshotSession.dismiss()
            }
        }

        Text {
            text: ScreenshotSession.countdown + "s"
            color: Theme.text.primary
            font.pixelSize: Theme.type.title.size
            font.weight: Theme.type.title.weight
            font.family: Theme.font.ui
            Layout.rightMargin: 6
        }
    }

    component ToolbarDivider: Rectangle {
        implicitWidth: 1
        implicitHeight: 24
        Layout.alignment: Qt.AlignVCenter
        Layout.leftMargin: 3
        Layout.rightMargin: 3
        color: Theme.stroke.hairline
    }

    component ModeButton: RowLayout {
        id: modeButton

        required property var modelData
        required property int index
        readonly property bool selected: ScreenshotSession.mode === modelData.id
        readonly property bool startsGroup: index > 0 && ScreenshotSession.modes[index - 1].group !== modelData.group

        spacing: Theme.space.xxs

        ToolbarDivider {
            visible: modeButton.startsGroup
        }

        Rectangle {
            implicitWidth: 36
            implicitHeight: 36
            radius: Theme.radius.md
            color: modeButton.selected || modeHover.hovered ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

            Behavior on color {
                ColorAnimation {
                    duration: Theme.motion.fast
                }
            }

            Text {
                anchors.centerIn: parent
                text: modeButton.modelData.glyph
                color: modeButton.selected ? Theme.text.primary : Theme.text.secondary
                font.pixelSize: Theme.icon.lg
                font.family: Theme.font.icon

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.motion.fast
                    }
                }
            }

            HoverHandler {
                id: modeHover

                cursorShape: Qt.PointingHandCursor
            }
            TapHandler {
                onTapped: ScreenshotSession.setMode(modeButton.modelData.id)
            }
        }
    }
}
