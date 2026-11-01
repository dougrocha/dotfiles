import QtQuick
import qs.Constants

Flickable {
    id: root

    property real bleed: Theme.panel.rowBleed
    property real limit: Infinity
    property Item host: null
    readonly property real cap: host ? host.scrollCap : Infinity
    default property alias content: column.data

    Component.onCompleted: {
        for (let item = parent; item; item = item.parent) {
            if (item.isPanelCard) {
                host = item;
                item.scroller = root;
                return;
            }
        }
    }

    x: -bleed
    width: parent.width + bleed * 2
    height: Math.min(column.implicitHeight, limit, cap)
    contentWidth: width
    contentHeight: column.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    interactive: contentHeight > height

    Column {
        id: column

        x: root.bleed
        width: root.width - root.bleed * 2
    }
}
