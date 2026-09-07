import QtQuick
import Quickshell
import qs.Components
import qs.Constants
import qs.Services

IconButton {
    glyph: PhosphorIcons.gear
    active: Visibilities.settingsPanel
    activeColor: Theme.text.primary
    onTapped: Visibilities.toggleSettings()
}
