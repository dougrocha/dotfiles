import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import qs.Constants

Item {
    id: root

    implicitWidth: mainLayout.width
    implicitHeight: Theme.topBarHeight

    RowLayout {
        id: mainLayout
        anchors.centerIn: parent
        Layout.alignment: Qt.AlignVCenter
        spacing: 4

        Repeater {
            model: SystemTray.items.values
            delegate: TrayItem {}
        }
    }
}
