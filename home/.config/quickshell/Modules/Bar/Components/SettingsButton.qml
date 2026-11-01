import QtQuick
import qs.Components
import qs.Constants
import qs.Services

IconButton {
    glyph: PhosphorIcons.gear
    plate: true
    open: Visibilities.isOpen(Visibilities.names.settings)
    active: open
    activeColor: Theme.text.primary
    tooltipText: "Settings"
    onTapped: Visibilities.toggle(Visibilities.names.settings)
}
