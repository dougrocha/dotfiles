import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.Components
import qs.Modules.Popups
import qs.Services

Item {
    id: root

    property color colYellow
    property color colMuted
    property int fontSize
    property string fontFamily
    readonly property bool showCider: CiderRpcService.isOnline

    implicitWidth: clickWrapper.implicitWidth
    implicitHeight: clickWrapper.implicitHeight

    WrapperMouseArea {
        id: clickWrapper

        cursorShape: showCider ? Qt.PointingHandCursor : Qt.ArrowCursor
        enabled: showCider
        onClicked: {
            musicPopup.visible = true;
        }

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
                color: root.colYellow
                font.pixelSize: root.fontSize
                font.family: root.fontFamily
                font.bold: true
                Layout.rightMargin: 8
                elide: Text.ElideRight
                Layout.maximumWidth: 200
            }

            Rectangle {
                visible: showCider
                Layout.preferredWidth: 1
                Layout.preferredHeight: 16
                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: 0
                Layout.rightMargin: 8
                color: root.colMuted
            }
        }
    }

    MusicPopup {
        id: musicPopup
        anchorItem: root
    }
}
