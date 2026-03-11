import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray

RowLayout {
    spacing: 4

    Repeater {
        model: SystemTray.items.values
        delegate: TrayItem {}
    }
}
