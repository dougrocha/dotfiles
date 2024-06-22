local beautiful = require("beautiful")
local gears = require("gears")

local config_dir = gears.filesystem.get_configuration_dir()
local themes_dir = config_dir .. "themes/"
local icons_dir = themes_dir .. "icons/"

local pallete = require("themes.palletes.catppuccin-macchiato")

local dpi = beautiful.xresources.apply_dpi

local hex_color_match = "[a-fA-F0-9][a-fA-F0-9]"
local function mix(color1, color2, ratio)
    ratio = ratio or 0.5
    local result = "#"
    local channels1 = color1:gmatch(hex_color_match)
    local channels2 = color2:gmatch(hex_color_match)
    for _ = 1, 3 do
        local bg_numeric_value = math.ceil(
            tonumber("0x" .. channels1()) * ratio
                + tonumber("0x" .. channels2()) * (1 - ratio)
        )
        if bg_numeric_value < 0 then
            bg_numeric_value = 0
        end
        if bg_numeric_value > 255 then
            bg_numeric_value = 255
        end
        result = result .. string.format("%02x", bg_numeric_value)
    end
    return result
end

local theme = {}

theme.path = themes_dir
theme.pallete = pallete

-- Fonts
theme.font_name = "SF Pro Display"
theme.font = "SF Pro Display 10"
theme.font_bold = "SF Pro Display Bold 10"
theme.font_alt = "SF Pro Display Italic 10"
theme.icon_theme = "Papirus Icons 16"

-- Transparency
theme.transparent = "#00000000"

-- Foreground
theme.fg_normal = pallete.text.hex
theme.fg_focus = pallete.mauve.hex
theme.fg_urgent = pallete.text.hex
-- theme.fg_minimize =

-- Background
theme.bg_normal = pallete.base.hex
theme.bg_focus = pallete.base.hex
theme.bg_urgent = pallete.red.hex
-- theme.bg_minimize =
theme.bg_systray = theme.bg_normal

theme.useless_gap = dpi(8)
theme.border_width = dpi(1)
theme.border_color_normal = pallete.base.hex
theme.border_color_active = pallete.mauve.hex
theme.border_color_marked = pallete.mauve.hex

theme.tasklist_bg_focus = pallete.base.hex

-- Wibar
theme.wibar_stretch = true
theme.wibar_height = dpi(36)
theme.wibar_bg = theme.bg_normal
theme.wibar_fg = theme.fg_normal
theme.align = "top"

-- Menu
theme.menu_height = dpi(24)
theme.menu_width = dpi(116)

-- Notification
theme.notification_font = theme.font
theme.notification_bg = theme.bg_normal
theme.notification_fg = theme.fg_normal
theme.notification_border_width = dpi(1)
theme.notification_border_color = pallete.blue.hex
theme.notification_shape = function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, dpi(10))
end
theme.notification_margin = dpi(8)
theme.notification_spacing = dpi(8)
theme.notification_icon_size = dpi(60)

-- Button
theme.button_bg = pallete.surface0.hex

local mix_color = mix(theme.bg_focus, theme.fg_normal)

-- Layout icons
theme.layout_floating =
    gears.color.recolor_image(icons_dir .. "layouts/floating.svg", mix_color)
theme.layout_max =
    gears.color.recolor_image(icons_dir .. "layouts/max.svg", mix_color)
theme.layout_tile =
    gears.color.recolor_image(icons_dir .. "layouts/tile.svg", mix_color)

theme.awesome_icon = beautiful.theme_assets.awesome_icon(
    theme.wibar_height,
    mix_color,
    theme.bg_normal
)

-- Volume Icons
theme.volume_off =
    gears.color.recolor_image(icons_dir .. "volume_off.svg", mix_color)
theme.volume_down =
    gears.color.recolor_image(icons_dir .. "volume_down.svg", mix_color)
theme.volume_up =
    gears.color.recolor_image(icons_dir .. "volume_up.svg", mix_color)
theme.volume_mute =
    gears.color.recolor_image(icons_dir .. "volume_mute.svg", mix_color)
theme.no_sound =
    gears.color.recolor_image(icons_dir .. "no_sound.svg", mix_color)

return theme
