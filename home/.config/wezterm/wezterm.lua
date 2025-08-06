local wezterm = require("wezterm")
local sessionizer = wezterm.plugin.require("https://github.com/mikkasendke/sessionizer.wezterm")
local history = wezterm.plugin.require("https://github.com/mikkasendke/sessionizer-history")

local action = wezterm.action

local HOME_DIR = wezterm.home_dir

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

local fd_path = "/opt/homebrew/bin/fd"

local schema = {
	options = { callback = history.Wrapper(sessionizer.DefaultCallback) },
	sessionizer.DefaultWorkspace({}),
	history.MostRecentWorkspace({}),

	HOME_DIR .. "/dev",
	HOME_DIR .. "/school",
	HOME_DIR .. "/second-brain",

	sessionizer.FdSearch({ HOME_DIR .. "/dev", include_submodules = true, fd_path = fd_path }),
	sessionizer.FdSearch({ HOME_DIR .. "/school", include_submodules = true, fd_path = fd_path }),

	processing = sessionizer.for_each_entry(function(entry)
		entry.label = entry.label:gsub(wezterm.home_dir, "~")
	end),
}

config.max_fps = 120
config.window_background_opacity = 0.9
config.window_decorations = "RESIZE"
config.font_size = 18.0
config.command_palette_font_size = 18.0

config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.default_workspace = "default"

config.color_scheme = "Gruvbox dark, hard (base16)"
config.font = wezterm.font("Monaspace Neon")
config.adjust_window_size_when_changing_font_size = false

config.set_environment_variables = {
	XDG_CONFIG_HOME = HOME_DIR .. "/.config",
	PATH = "/opt/homebrew/bin:/opt/homebrew/sbin:" .. os.getenv("PATH"),
}
config.default_prog = { "nu", "-l" }
config.unix_domains = { { name = "unix" } }
config.default_gui_startup_args = { "connect", "unix" }

config.keys = {
	{ key = "s", mods = "CTRL|SHIFT", action = action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "v", mods = "CTRL|SHIFT", action = action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

	{ key = "h", mods = "CTRL|SHIFT", action = action.ActivatePaneDirection("Left") },
	{ key = "j", mods = "CTRL|SHIFT", action = action.ActivatePaneDirection("Down") },
	{ key = "k", mods = "CTRL|SHIFT", action = action.ActivatePaneDirection("Up") },
	{ key = "l", mods = "CTRL|SHIFT", action = action.ActivatePaneDirection("Right") },

	{ key = "q", mods = "CTRL|SHIFT", action = action.CloseCurrentPane({ confirm = false }) },
	{ key = "z", mods = "CTRL|SHIFT", action = action.TogglePaneZoomState },

	{ key = "p", mods = "CTRL|SHIFT", action = action.ActivateCommandPalette },

	{ key = "g", mods = "CTRL|SHIFT", action = sessionizer.show(schema) },
}

config.status_update_interval = 1000
wezterm.on("update-right-status", function(window, pane)
	window:set_right_status(window:active_workspace())
end)

return config
