import qs.Constants

IconButton {
    property string icon: ""
    property int iconSize: Theme.icon.md

    glyph: icon
    glyphSize: iconSize
    box: iconSize + Theme.space.xl
    solid: true
    hoverFill: true
    restColor: Theme.text.primary
    hoverColor: Theme.text.primary
}
