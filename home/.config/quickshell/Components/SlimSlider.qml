import QtQuick
import Quickshell.Widgets
import qs.Constants

Item {
    id: slimRoot

    property string iconSource: ""
    property string labelText: ""
    property string sublabelText: ""
    property real sliderValue: 0
    property real sliderMax: 1.5
    property bool muted: false
    property string muteIcon: ""
    property string mutedIcon: ""

    property int trackBleed: 0

    readonly property int labelIndent: iconSource !== "" ? 26 : 0

    signal moved(real value)
    signal muteToggled

    implicitHeight: slimCol.implicitHeight

    Column {
        id: slimCol
        width: parent.width
        spacing: Theme.space.xs

        Item {
            width: parent.width
            height: slimRoot.sublabelText !== "" ? 36 : 32

            IconImage {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                implicitSize: 16
                source: slimRoot.iconSource
                visible: slimRoot.iconSource !== ""
            }

            Text {
                id: mainLabel
                anchors.left: parent.left
                anchors.leftMargin: slimRoot.labelIndent
                anchors.right: muteBtn.left
                anchors.rightMargin: 8
                anchors.top: slimRoot.sublabelText !== "" ? parent.top : undefined
                anchors.verticalCenter: slimRoot.sublabelText !== "" ? undefined : parent.verticalCenter
                text: slimRoot.labelText
                color: Theme.text.primary
                font.pixelSize: Theme.type.body.size
                font.family: Theme.font.ui
                elide: Text.ElideRight
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: slimRoot.labelIndent
                anchors.right: muteBtn.left
                anchors.rightMargin: 8
                anchors.top: mainLabel.bottom
                anchors.topMargin: 1
                visible: slimRoot.sublabelText !== ""
                text: slimRoot.sublabelText
                color: Theme.text.tertiary
                font.pixelSize: Theme.type.caption.size
                font.family: Theme.font.ui
                elide: Text.ElideRight
            }

            Rectangle {
                id: muteBtn
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 24
                height: 24
                radius: Theme.radius.sm
                activeFocusOnTab: true
                color: muteHover.hovered || activeFocus ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.motion.fast
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: slimRoot.muted ? slimRoot.mutedIcon : slimRoot.muteIcon
                    color: slimRoot.muted ? Theme.danger : muteHover.hovered || muteBtn.activeFocus ? Theme.accent : Theme.text.secondary
                    font.pixelSize: Theme.icon.sm

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.motion.fast
                        }
                    }
                    font.family: Theme.font.icon
                }

                HoverHandler {
                    id: muteHover
                    cursorShape: Qt.PointingHandCursor
                }
                TapHandler {
                    onTapped: slimRoot.muteToggled()
                }
                Keys.onPressed: function (event) {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                        slimRoot.muteToggled();
                        event.accepted = true;
                    }
                }
            }
        }

        StyledSlider {
            x: -slimRoot.trackBleed
            width: parent.width + slimRoot.trackBleed * 2
            from: 0
            to: slimRoot.sliderMax
            boundValue: slimRoot.sliderValue
            onMoved: slimRoot.moved(value)

            TapHandler {
                enabled: slimRoot.sliderMax > 1
                onDoubleTapped: slimRoot.moved(1)
            }
        }
    }
}
