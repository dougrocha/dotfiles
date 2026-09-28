import QtQuick
import Quickshell
import qs.Components
import qs.Constants
import qs.Services

IconButton {
    glyph: PhosphorIcons.gear
    active: Visibilities.isOpen("settings-panel")
    activeColor: Theme.text.primary
    tooltipText: "Settings"
    onTapped: Visibilities.toggle("settings-panel")
}
