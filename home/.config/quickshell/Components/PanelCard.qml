import QtQuick
import qs.Constants

Rectangle {
    id: card

    property bool menu: false
    property real maxHeight: Infinity
    readonly property bool isPanelCard: true
    readonly property real padding: menu ? Theme.row.inset : Theme.panel.padding
    property Item scroller: null
    property real scrollCap: Infinity
    default property alias content: column.data

    function fit(): void {
        if (!scroller)
            return;
        const chrome = column.implicitHeight - (scroller.visible ? scroller.height : 0);
        scrollCap = Math.max(0, maxHeight - padding * 2 - chrome);
    }

    onMaxHeightChanged: fit()
    onScrollerChanged: fit()

    implicitWidth: menu ? Theme.panel.menuWidth : Theme.panel.width
    implicitHeight: column.implicitHeight + padding * 2
    radius: Theme.radius.surface
    color: menu ? Theme.colors.raised : Theme.colors.surface
    border.color: Theme.stroke.hairline
    border.width: menu ? 1 : 0
    clip: true

    Connections {
        target: column

        function onImplicitHeightChanged() {
            card.fit();
        }
    }

    Column {
        id: column

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: card.padding
        spacing: Theme.space.xl
    }
}
