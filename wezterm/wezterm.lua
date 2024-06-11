local wezterm = require("wezterm")

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- config.colors = require("lua/kanagawa").colors
-- config.force_reverse_video_cursor = require("lua/kanagawa").force_reverse_video_cursor

config.color_scheme = "Catppuccin Macchiato"

config.window_background_opacity = 0.85

config.window_padding = {
	bottom = 0,
}

config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true

-- Font
config.font = wezterm.font_with_fallback({
	"Monaspace Neon",
	"Caskaydia Cove Nerd Font",
	"monospace",
})

-- Default Shell
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	config.default_prog = { "pwsh.exe" }
end

return config
