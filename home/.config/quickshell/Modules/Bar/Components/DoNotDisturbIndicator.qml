import QtQuick
import qs.Components
import qs.Constants
import qs.Services

IconButton {
    plate: true
    visible: SettingsService.doNotDisturb
    glyph: PhosphorIcons.bellSlash
    tooltipText: "Do not disturb"
    onTapped: SettingsService.doNotDisturb = false
}
