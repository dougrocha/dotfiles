import QtQuick
import Quickshell
import Quickshell.Io
import qs.Components
import qs.Constants
import qs.Services

IconButton {
    glyph: PhosphorIcons.cpu
    active: CpuService.usage > 80
    activeColor: Theme.danger
    tooltipText: "CPU  " + CpuService.usage + "%"
    onTapped: {
        Visibilities.closePopups();
        proc.running = true;
    }

    Process {
        id: proc
        command: ["launch-or-focus-tui", "btop"]
    }
}
