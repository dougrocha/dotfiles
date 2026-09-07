import QtQuick
import Quickshell
import qs.Components
import qs.Constants
import qs.Services

IconButton {
    glyph: {
        if (AudioService.muted || AudioService.volume <= 0)
            return PhosphorIcons.speakerSlash;
        if (AudioService.volume < 0.34)
            return PhosphorIcons.speakerNone;
        if (AudioService.volume < 0.67)
            return PhosphorIcons.speakerLow;
        return PhosphorIcons.speakerHigh;
    }
    active: AudioService.muted
    activeColor: Theme.danger
    tooltipText: AudioService.muted ? "Volume · Muted" : "Volume · " + Math.round(AudioService.volume * 100) + "%"
    onTapped: Visibilities.toggleSoundPanel()
}
