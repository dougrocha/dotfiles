pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    property string tooltipText: ""
    property real tooltipX: 0
    property bool tooltipShown: false
    property var tooltipOwner: null

    function showTooltip(text, x, owner) {
        if (!text)
            return;
        tooltipText = text;
        tooltipX = x;
        tooltipOwner = owner ?? null;
        tooltipShown = true;
    }

    function hideTooltip(owner) {
        if (owner === undefined || owner === null || tooltipOwner === owner) {
            tooltipShown = false;
            tooltipOwner = null;
        }
    }

    // Auto-hide when the owning widget disappears mid-hover
    Connections {
        target: root.tooltipOwner
        ignoreUnknownSignals: true
        function onVisibleChanged() {
            if (root.tooltipOwner && !root.tooltipOwner.visible) {
                root.tooltipShown = false;
                root.tooltipOwner = null;
            }
        }
    }
}
