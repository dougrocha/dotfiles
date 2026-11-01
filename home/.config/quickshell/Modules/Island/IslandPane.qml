import QtQuick
import qs.Components
import qs.Constants

Item {
    id: pane

    property bool shown: false
    property bool pop: false

    opacity: shown ? 1 : 0
    visible: opacity > 0
    scale: pop ? Theme.motion.scaleFrom + (1 - Theme.motion.scaleFrom) * opacity : 1
    transformOrigin: Item.Top

    ContentFade on opacity {}
}
