import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.Services

Item {
    id: root

    property color colYellow
    property color colMuted
    property int fontSize
    property string fontFamily
    property bool panelOpen: false

    signal togglePanel

    readonly property bool showCider: CiderRpcService.isOnline

    implicitWidth: clickWrapper.implicitWidth
    implicitHeight: clickWrapper.implicitHeight

    WrapperMouseArea {
        id: clickWrapper

        cursorShape: showCider ? Qt.PointingHandCursor : Qt.ArrowCursor
        enabled: showCider
        onClicked: root.togglePanel()

        RowLayout {
            id: mediaLayout

            Text {
                visible: showCider
                text: {
                    var title = CiderRpcService.trackTitle || "";
                    var artist = CiderRpcService.trackArtist || "";
                    if (artist && artist.length > 0 && title && title.length > 0)
                        return artist + " - " + title;

                    return title;
                }
                color: root.panelOpen ? Qt.lighter(root.colYellow, 1.3) : root.colYellow
                font.pixelSize: root.fontSize
                font.family: root.fontFamily
                font.bold: true
                elide: Text.ElideRight
                Layout.maximumWidth: 240

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
            }
        }
    }
}
