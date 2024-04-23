local wezterm = require("wezterm")

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.colors = require("lua/rose-pine").colors()
config.window_frame = require("lua/rose-pine").window_frame()

-- Theme
-- config.color_scheme = "Dracula (Official)"
-- Kanagawa Color Scheme
-- config.force_reverse_video_cursor = true
-- config.colors = {
-- 	foreground = "#dcd7ba",
-- 	background = "#1f1f28",
--
-- 	cursor_bg = "#c8c093",
-- 	cursor_fg = "#c8c093",
-- 	cursor_border = "#c8c093",
--
-- 	selection_fg = "#c8c093",
-- 	selection_bg = "#2d4f67",
--
-- 	scrollbar_thumb = "#16161d",
-- 	split = "#16161d",
--
-- 	ansi = { "#090618", "#c34043", "#76946a", "#c0a36e", "#7e9cd8", "#957fb8", "#6a9589", "#c8c093" },
-- 	brights = { "#727169", "#e82424", "#98bb6c", "#e6c384", "#7fb4ca", "#938aa9", "#7aa89f", "#dcd7ba" },
-- 	indexed = { [16] = "#ffa066", [17] = "#ff5d62" },
-- }

config.window_background_opacity = 0.85

config.window_padding = {
	top = 0,
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
else
	-- HANDLE MACOS AND LINUX
end

return config
