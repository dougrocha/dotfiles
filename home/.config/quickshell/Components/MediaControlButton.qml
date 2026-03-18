import QtQuick
import QtQuick.Layouts
import qs.Components

Item {
    id: root

    property string icon: ""
    property int size: 24
    property bool isPrimary: false
    property color iconColor: Colors.on_surface
    property bool enabled: true
    property var onClicked: function () {}

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
            color: root.enabled ? root.iconColor : Qt.rgba(root.iconColor.r, root.iconColor.g, root.iconColor.b, 0.4)
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
                    buttonBackground.color = Qt.rgba(Colors.on_surface.r, Colors.on_surface.g, Colors.on_surface.b, 0.12);
                else
                    buttonBackground.color = "transparent";
            }
        }
    }
}
