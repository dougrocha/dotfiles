---@class User
user = {
    config = "wezterm start nvim '~/.config/awesome/'",
    editor = "nvim",
    editor_cmd = "wezterm -e nvim",
    files = "nemo",
    font = "RobotoMono 10",
    font_alt = "RobotoMono Italic 10",
    font_icon = "Material Icons 16",
    terminal = "wezterm",
    shutdown = "systemctl poweroff",
    reboot = "systemctl reboot",
    screenshot_dir = "~/Pictures/Screenshots/",
}

pcall(require, "luarocks.loader")

local awful = require("awful")
local beautiful = require("beautiful")

require("awful.autofocus")

awful.util.shell = "sh"

beautiful.init(
    require("gears").filesystem.get_configuration_dir()
        .. "themes/catppuccin.lua"
)

awful.spawn.with_shell("~/.config/awesome/autostart.sh")

require("layout")

require("config")
require("signals")
require("notifications")

require("awful.hotkeys_popup.keys")
