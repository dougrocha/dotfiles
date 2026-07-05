import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Constants
import qs.Modules.Notifications
import qs.Services

PanelWindow {
    id: panel

    color: "transparent"
    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs.notification_center"
    WlrLayershell.keyboardFocus: Visibilities.notificationCenter ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    visible: container.reveal > 0.001

    onVisibleChanged: {
        if (visible)
            calendarView.reset();
    }

    MouseArea {
        anchors.fill: parent
        onClicked: Visibilities.notificationCenter = false
    }

    Item {
        id: container

        property real reveal: Visibilities.notificationCenter ? 1 : 0
        Behavior on reveal {
            NumberAnimation {
                duration: Visibilities.notificationCenter ? 160 : 120
                easing.type: Visibilities.notificationCenter ? Easing.OutCubic : Easing.InCubic
            }
        }

        width: 322
        height: stack.implicitHeight
        x: parent.width - width - 8
        y: Theme.topBarHeight + 6
        opacity: reveal
        transform: Translate {
            y: (1 - container.reveal) * -6
        }

        focus: Visibilities.notificationCenter
        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Escape) {
                Visibilities.notificationCenter = false;
                event.accepted = true;
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        Column {
            id: stack
            width: parent.width
            spacing: 6

            NotificationHistory {
                width: parent.width
            }

            Rectangle {
                width: parent.width
                height: calendarView.implicitHeight + 32
                radius: 12
                color: Colors.surface_container
                border.width: 1
                border.color: Colors.outline_variant

                Behavior on height {
                    NumberAnimation {
                        duration: Theme.animations.normal
                        easing.type: Easing.OutCubic
                    }
                }

                CalendarView {
                    id: calendarView
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: 16
                    }
                }
            }
        }
    }
}
