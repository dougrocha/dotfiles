import qs.Constants

IconButton {
    property string icon: ""
    property int iconSize: 20

    glyph: icon
    glyphSize: iconSize
    box: filled ? 0 : 28
    restColor: Theme.text.primary
    hoverColor: Theme.accent
}
