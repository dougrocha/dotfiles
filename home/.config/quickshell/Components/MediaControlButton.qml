import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property string icon: ""
    property int size: 24
    property bool isPrimary: false
    property string iconColor: "#ffffff"
    property bool enabled: true
    property var onClicked: function() {
    }

    implicitWidth: size
    implicitHeight: size

    Rectangle {
        id: buttonBackground

        anchors.centerIn: parent
        width: isPrimary ? 56 : size
        height: isPrimary ? 56 : size
        radius: isPrimary ? 28 : size / 2
        color: "transparent"

        Text {
            anchors.centerIn: parent
            text: root.icon
            color: root.enabled ? root.iconColor : root.iconColor + "66"
            font.pixelSize: root.size
            font.family: "JetBrainsMono Nerd Font"
            font.bold: true
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            enabled: root.enabled
            onClicked: {
                if (root.onClicked)
                    root.onClicked();

            }
            onContainsMouseChanged: {
                if (containsMouse && root.enabled)
                    buttonBackground.color = "#ffffff20";
                else
                    buttonBackground.color = "transparent";
            }
        }

    }

}
