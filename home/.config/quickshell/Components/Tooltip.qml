import QtQuick
import qs.Services

Item {
    id: root

    property string text: ""
    property Item targetItem: null
    property bool hovered: false
    readonly property int delay: 500

    onHoveredChanged: {
        if (hovered) {
            delayTimer.restart();
        } else {
            delayTimer.stop();
            TooltipService.hideTooltip(targetItem);
        }
    }

    onTextChanged: {
        if (TooltipService.tooltipOwner === targetItem)
            TooltipService.tooltipText = text;
    }

    Timer {
        id: delayTimer
        interval: root.delay
        onTriggered: {
            if (!root.text || !root.targetItem)
                return;
            const p = root.targetItem.mapToItem(null, root.targetItem.width / 2, 0);
            TooltipService.showTooltip(root.text, p.x, root.targetItem);
        }
    }
}
