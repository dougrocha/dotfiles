import QtQuick
import qs.Components
import qs.Constants
import qs.Services

IconButton {
    glyph: PhosphorIcons.gear
    active: Visibilities.isOpen(Visibilities.names.settings)
    activeColor: Theme.text.primary
    tooltipText: "Settings"
    onTapped: Visibilities.toggle(Visibilities.names.settings)
}
