import QtQuick
import qs.Components
import qs.Constants
import qs.Services

IconButton {
    glyph: AudioService.speakerGlyph(AudioService.volume, AudioService.muted)
    active: AudioService.muted || Visibilities.isOpen(Visibilities.names.sound)
    activeColor: AudioService.muted ? Theme.danger : Theme.text.primary
    tooltipText: AudioService.muted ? "Volume: muted" : "Volume: " + Math.round(AudioService.volume * 100) + "%"
    onTapped: Visibilities.toggle(Visibilities.names.sound)
}
