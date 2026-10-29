import QtQuick
import Quickshell
import qs.Constants
import qs.Services

Column {
    id: footer

    required property string label
    required property list<string> command

    width: parent ? parent.width : implicitWidth
    spacing: Theme.space.sm

    Divider {}

    PanelRow {
        implicitHeight: 28
        onTapped: {
            Visibilities.dismissAll();
            Quickshell.execDetached(footer.command);
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: footer.label
            color: Theme.text.primary
            font.family: Theme.font.ui
            font.pixelSize: Theme.type.body.size
        }
    }
}
