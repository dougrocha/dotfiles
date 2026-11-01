pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Constants
import qs.Modules.Bar.Components
import qs.Services
import qs.Widgets

Item {
    id: root

    required property var screen
    property bool autoHide: false
    readonly property Item settingsButton: settingsButtonItem
    readonly property Item volumeIndicator: volumeIndicatorItem
    readonly property Item bluetoothIndicator: bluetoothIndicatorItem
    readonly property Item clockButton: clockButtonItem

    TapHandler {
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onTapped: eventPoint => {
            if (!traySection.contains(traySection.mapFromItem(root, eventPoint.position)))
                Visibilities.closeTrayMenu();
        }
    }

    Rectangle {
        id: tint
        anchors.fill: parent

        function tintAt(alpha) {
            return Theme.withAlpha(Theme.colors.bg, root.autoHide ? 1 : alpha);
        }

        gradient: Gradient {
            GradientStop {
                position: 0
                color: tint.tintAt(Theme.bar.tintTop)
            }
            GradientStop {
                position: 0.55
                color: tint.tintAt(Theme.bar.tintMid)
            }
            GradientStop {
                position: 1
                color: tint.tintAt(0)
            }
        }
    }

    Workspaces {
        screen: root.screen
        anchors.left: parent.left
        anchors.leftMargin: Theme.bar.edgeMargin
        anchors.verticalCenter: parent.verticalCenter
    }

    RowLayout {
        id: indicatorRow
        anchors.right: parent.right
        anchors.rightMargin: Theme.bar.edgeMargin
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.space.xxs

        TraySection {
            id: traySection
        }

        CpuIndicator {}

        BluetoothIndicator {
            id: bluetoothIndicatorItem
        }

        VolumeIndicator {
            id: volumeIndicatorItem
        }

        SettingsButton {
            id: settingsButtonItem
        }

        DoNotDisturbIndicator {}

        ClockButton {
            id: clockButtonItem
        }
    }
}
