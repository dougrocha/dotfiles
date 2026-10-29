import QtQuick
import Quickshell
import qs.Components
import qs.Constants
import qs.Services

IconButton {
    glyph: PhosphorIcons.cpu
    active: CpuService.usage > 80
    activeColor: Theme.danger
    tooltipText: "CPU: " + CpuService.usage + "%"
    onTapped: {
        Visibilities.dismissAll();
        Quickshell.execDetached(["launch-or-focus-tui", "btop"]);
    }
}
