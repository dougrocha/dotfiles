import QtQuick
import Quickshell

QtObject {
    id: root

    required property var trayItem
    readonly property var menuActionOverrides: [
        {
            "identities": ["localsend", "local send"],
            "action": "Open"
        }
    ]
    readonly property var titleOverrides: [
        {
            "identities": ["localsend", "local send"],
            "title": "LocalSend"
        }
    ]

    function identity() {
        return `${root.trayItem.id || ""} ${root.trayItem.title || ""}`.toLowerCase();
    }

    function matches(override) {
        const trayIdentity = root.identity();
        return override.identities.some(candidate => trayIdentity.includes(candidate));
    }

    function triggerPrimaryAction() {
        for (const override of root.menuActionOverrides) {
            if (root.matches(override))
                return root.triggerMenuEntry(override.action);
        }
        return false;
    }

    function displayTitle() {
        for (const override of root.titleOverrides) {
            if (root.matches(override))
                return override.title;
        }

        if (root.trayItem.tooltipTitle)
            return root.trayItem.tooltipTitle;
        if (root.trayItem.title) {
            const title = root.trayItem.title;
            const looksLikeBundleId = /^[a-z0-9-]+(\.[a-z0-9_-]+){2,}$/.test(title) && /[a-z]/.test(title);
            if (looksLikeBundleId) {
                const lastPart = title.slice(title.lastIndexOf(".") + 1);
                const cleaned = lastPart.replace(/[_-]+/g, " ").replace(/\b\w/g, character => character.toUpperCase()).replace(/\sApp$/i, "");
                return cleaned || title;
            }
            return title;
        }
        return root.trayItem.id;
    }

    function triggerMenuEntry(label) {
        const entries = menuOpener.children.values;
        for (let i = 0; i < entries.length; ++i) {
            const entry = entries[i];
            if (entry && entry.enabled && !entry.isSeparator && entry.text === label) {
                entry.triggered();
                return true;
            }
        }
        return false;
    }

    // Some applications export Activate without implementing a handler. Keep
    // their menu openers ready so the configured menu action can replace it.
    property QsMenuOpener menuOpener: QsMenuOpener {
        menu: root.trayItem.hasMenu ? root.trayItem.menu : null
    }
}
