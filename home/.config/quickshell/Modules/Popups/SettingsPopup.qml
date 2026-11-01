import QtQuick
import qs.Components
import qs.Services

Popup {
    id: popup

    panelName: Visibilities.names.settings
    onOpened: content.refresh()

    SettingsPanel {
        id: content

        width: parent.width
        onCloseRequested: popup.close()
    }
}
