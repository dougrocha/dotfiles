local wezterm = require("wezterm")
local sessionizer = wezterm.plugin.require("https://github.com/mikkasendke/sessionizer.wezterm")

local action = wezterm.action

local HOME_DIR = os.getenv("HOME")

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

sessionizer.apply_to_config(config)
sessionizer.config.command_options.fd_path = "/opt/homebrew/bin/fd"
sessionizer.config.paths = {
	HOME_DIR .. "/dev",
	HOME_DIR .. "/school",
}
sessionizer.config.additional_directories = {
	HOME_DIR .. "/dev",
	HOME_DIR .. "/school",
	HOME_DIR .. "/second-brain",
}
sessionizer.config.show_default = true

config.max_fps = 120
config.window_background_opacity = 0.9
config.window_decorations = "RESIZE"
config.font_size = 18.0
config.command_palette_font_size = 18.0

config.window_padding = {
	left = 2,
	right = 2,
	top = 0,
	bottom = 0,
}
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.default_workspace = "~"

config.color_scheme = "Gruvbox dark, hard (base16)"
config.font = wezterm.font("Monaspace Neon")
config.adjust_window_size_when_changing_font_size = false

config.set_environment_variables = {
	XDG_CONFIG_HOME = HOME_DIR .. "/.config",
	PATH = "/opt/homebrew/bin:" .. os.getenv("PATH"),
}
config.default_prog = { "nu", "-l" }
config.unix_domains = { { name = "unix" } }
config.default_gui_startup_args = { "connect", "unix" }

config.keys = {
	{ key = "_", mods = "CTRL|SHIFT", action = action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "|", mods = "CTRL|SHIFT", action = action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

	{ key = "h", mods = "CTRL|SHIFT", action = action.ActivatePaneDirection("Left") },
	{ key = "j", mods = "CTRL|SHIFT", action = action.ActivatePaneDirection("Down") },
	{ key = "k", mods = "CTRL|SHIFT", action = action.ActivatePaneDirection("Up") },
	{ key = "l", mods = "CTRL|SHIFT", action = action.ActivatePaneDirection("Right") },

	{ key = "w", mods = "CTRL|SHIFT", action = action.CloseCurrentPane({ confirm = false }) },
	{ key = "z", mods = "CTRL|SHIFT", action = action.TogglePaneZoomState },

	{ key = "p", mods = "ALT|SHIFT", action = action.ActivateCommandPalette },

	-- { key = "w", mods = "CTRL|SHIFT", action = action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },

	{ key = "p", mods = "CTRL|SHIFT", action = sessionizer.show },
}

config.status_update_interval = 1000
wezterm.on("update-right-status", function(window, pane)
	window:set_right_status(window:active_workspace())
end)

return config
