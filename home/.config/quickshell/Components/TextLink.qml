import QtQuick
import qs.Constants

Text {
    id: link

    signal tapped

    color: linkHover.hovered ? Theme.text.primary : Theme.text.secondary
    font.family: Theme.font.ui
    font.pixelSize: Theme.type.label.size
    font.weight: Theme.type.label.weight

    Behavior on color {
        ColorAnimation {
            duration: Theme.motion.fast
        }
    }

    HoverHandler {
        id: linkHover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: link.tapped()
    }
}
