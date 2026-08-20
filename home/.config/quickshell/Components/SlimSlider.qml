import QtQuick
import Quickshell.Widgets
import qs.Constants

Item {
    id: slimRoot

    property string iconSource: ""
    property string labelText: ""
    // Optional second line under the label; empty hides it.
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
            height: slimRoot.sublabelText !== "" ? 30 : 16

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
                anchors.right: pctLabel.left
                anchors.rightMargin: 8
                anchors.top: slimRoot.sublabelText !== "" ? parent.top : undefined
                anchors.verticalCenter: slimRoot.sublabelText !== "" ? undefined : parent.verticalCenter
                text: slimRoot.labelText
                color: Colors.on_surface_variant
                font.pixelSize: Fonts.small
                font.family: Fonts.font
                elide: Text.ElideRight
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: slimRoot.labelIndent
                anchors.right: parent.right
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

            Text {
                id: pctLabel
                anchors.right: muteBtn.left
                anchors.rightMargin: 8
                anchors.verticalCenter: mainLabel.verticalCenter
                text: Math.round(slimRoot.sliderValue * 100) + "%"
                color: Colors.on_surface_variant
                font.pixelSize: Fonts.small
                font.family: Fonts.font
            }

            Text {
                id: muteBtn
                anchors.right: parent.right
                anchors.verticalCenter: mainLabel.verticalCenter
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

        StyledSlider {
            width: parent.width
            from: 0
            to: slimRoot.sliderMax
            boundValue: slimRoot.sliderValue
            onMoved: slimRoot.moved(value)
        }
    }
}
