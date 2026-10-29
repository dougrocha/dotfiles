pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Components
import qs.Constants
import qs.Services

Rectangle {
    id: options

    required property real outputX
    required property real outputY
    required property Item toolbarItem
    readonly property point placed: ScreenshotSession.optionsPosition(toolbarItem.x - outputX, toolbarItem.y - outputY, toolbarItem.width, toolbarItem.height, width, height)

    x: outputX + placed.x
    y: outputY + placed.y
    enabled: ScreenshotSession.optionsOpen
    implicitWidth: 248
    implicitHeight: optionsColumn.implicitHeight + 16
    radius: Theme.radius.lg
    color: Theme.colors.surface
    border.width: 1
    border.color: Theme.stroke.hairline
    visible: presence.mapped
    opacity: presence.progress
    scale: presence.scale
    transformOrigin: Item.Bottom

    Presence {
        id: presence

        active: ScreenshotSession.optionsOpen
    }

    HoverHandler {
        blocking: true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {}
    }

    ColumnLayout {
        id: optionsColumn

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 8
        }
        spacing: 0

        ScreenshotOptionHeader {
            text: "Save to"
        }

        Repeater {
            model: ScriptModel {
                values: ScreenshotSession.saveLocations
                objectProp: "path"
            }

            delegate: ScreenshotOptionRow {
                required property var modelData

                implicitHeight: 28
                glyphSize: Theme.icon.sm
                label: modelData.label
                checked: modelData.checked
                onTapped: ScreenshotSession.chooseSaveLocation(modelData.path)
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 28
            radius: Theme.radius.sm
            color: otherLocationHover.hovered ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 28
                anchors.verticalCenter: parent.verticalCenter
                text: "Other location…"
                color: Theme.accent
                font.pixelSize: Theme.type.body.size
                font.weight: Theme.type.title.weight
                font.family: Theme.font.ui
            }

            HoverHandler {
                id: otherLocationHover

                cursorShape: Qt.PointingHandCursor
            }
            TapHandler {
                onTapped: ScreenshotSession.browseSaveLocation()
            }
        }

        OptionDivider {}

        ScreenshotOptionHeader {
            text: "Timer"
        }

        RowLayout {
            spacing: Theme.space.xxs
            Layout.fillWidth: true

            Repeater {
                model: ScreenshotSession.delays

                delegate: Rectangle {
                    id: delayChip

                    required property int modelData
                    readonly property bool selected: ScreenshotSession.delay === modelData

                    Layout.fillWidth: true
                    implicitHeight: 26
                    radius: Theme.radius.sm
                    color: selected ? Theme.fill.selected : (delayHover.hovered ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0))

                    Text {
                        anchors.centerIn: parent
                        text: delayChip.modelData === 0 ? "None" : delayChip.modelData + "s"
                        color: delayChip.selected ? Theme.text.primary : Theme.text.secondary
                        font.pixelSize: Theme.type.body.size
                        font.family: Theme.font.ui
                    }

                    HoverHandler {
                        id: delayHover

                        cursorShape: Qt.PointingHandCursor
                    }
                    TapHandler {
                        onTapped: ScreenshotSession.setDelay(delayChip.modelData)
                    }
                }
            }
        }

        OptionDivider {}

        ScreenshotOptionHeader {
            text: "Options"
        }

        Repeater {
            model: ScreenshotSession.optionList.filter(option => option.section === "Options")

            delegate: OptionToggle {}
        }

        OptionDivider {}

        ScreenshotOptionHeader {
            text: "Capture"
        }

        Repeater {
            model: ScreenshotSession.optionList.filter(option => option.section === "Capture")

            delegate: OptionToggle {}
        }

        Item {
            implicitHeight: 2
        }
    }

    component OptionDivider: Rectangle {
        Layout.fillWidth: true
        implicitHeight: 1
        color: Theme.stroke.hairline
        Layout.topMargin: 4
        Layout.bottomMargin: 1
    }

    component OptionToggle: ScreenshotOptionRow {
        required property var modelData

        label: modelData.label
        checked: ScreenshotSession.options[modelData.key]
        onTapped: ScreenshotSession.toggleOption(modelData.key)
    }
}
