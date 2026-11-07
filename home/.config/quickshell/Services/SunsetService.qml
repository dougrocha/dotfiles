pragma Singleton
import QtQuick
import Quickshell
import qs.Components

Singleton {
    id: root

    readonly property bool active: toggler.active

    function refresh(): void {
        toggler.refresh();
    }

    function toggle(): void {
        toggler.toggle();
    }

    UserUnitToggle {
        id: toggler

        unit: "hyprsunset.service"
        toggleCommand: ["toggle-sunset"]
    }
}
