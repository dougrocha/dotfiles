import QtQuick
import QtQuick.Layouts
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

    implicitWidth: mediaLayout.implicitWidth
    implicitHeight: mediaLayout.implicitHeight

    RowLayout {
        id: mediaLayout

        Text {
            visible: root.showCider
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

    HoverHandler {
        cursorShape: root.showCider ? Qt.PointingHandCursor : Qt.ArrowCursor
    }

    TapHandler {
        enabled: root.showCider
        onTapped: root.togglePanel()
    }
}
