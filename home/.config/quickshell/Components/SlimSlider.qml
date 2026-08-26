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

    readonly property int labelIndent: iconSource !== "" ? 26 : 0

    signal moved(real value)
    signal muteToggled

    implicitHeight: slimCol.implicitHeight

    Column {
        id: slimCol
        width: parent.width
        spacing: 4

        Item {
            width: parent.width
            height: slimRoot.sublabelText !== "" ? 36 : 32

            IconImage {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                implicitSize: 18
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
                color: Colors.on_surface_variant
                font.pixelSize: Fonts.body.size
                font.family: Fonts.font
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
                color: Colors.outline
                font.pixelSize: Fonts.caption
                font.family: Fonts.font
                elide: Text.ElideRight
            }

            Rectangle {
                id: muteBtn
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 32
                height: 32
                radius: Theme.blockRadius
                activeFocusOnTab: true
                color: muteHover.hovered || activeFocus ? Colors.surface_container_highest : Colors.surface_container
                border.width: activeFocus ? 1 : 0
                border.color: slimRoot.muted ? Colors.error : Colors.primary

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animations.fast
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: slimRoot.muted ? slimRoot.mutedIcon : slimRoot.muteIcon
                    color: slimRoot.muted ? Colors.error : Colors.primary
                    font.pixelSize: Fonts.h5
                    font.family: Fonts.iconFont
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
            width: parent.width
            from: 0
            to: slimRoot.sliderMax
            boundValue: slimRoot.sliderValue
            onMoved: slimRoot.moved(value)
        }
    }
}
