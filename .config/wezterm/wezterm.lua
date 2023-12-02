local wezterm = require("wezterm")

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Theme
config.color_scheme = "Dracula (Official)"

config.window_background_opacity = 0.95

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
