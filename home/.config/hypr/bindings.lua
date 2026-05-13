local mainMod = "SUPER"

local function bind(keys, action, opts)
    local key_str = mainMod .. " + " .. table.concat(keys, " + ")
    hl.bind(key_str, action, opts)
end

-- Programs
bind({ "RETURN" }, hl.dsp.exec_cmd("uwsm-app -- xdg-terminal-exec"))
bind({ "W" }, hl.dsp.window.close())
bind({ "E" }, hl.dsp.exec_cmd("uwsm-app -- nautilus --new-window"))
bind({ "SPACE" }, hl.dsp.exec_cmd("launch-walker"))
bind({ "B" }, hl.dsp.exec_cmd("uwsm-app -- $(xdg-settings get default-web-browser)"))

bind({ "S" }, hl.dsp.workspace.toggle_special("scratchpad"))
bind({ "SHIFT", "S" }, hl.dsp.window.move({ workspace = "special:scratchpad" }))

-- Tiling
bind({ "P" }, hl.dsp.window.pseudo())
bind({ "M" }, hl.dsp.layout("togglesplit"))
bind({ "T" }, hl.dsp.window.float({ action = "toggle" }))
bind({ "F" }, hl.dsp.window.fullscreen({ mode = "fullscreen" }))
bind({ "CTRL", "F" }, hl.dsp.window.fullscreen_state({ internal = 0, client = 2 }))
bind({ "ALT", "F" }, hl.dsp.window.fullscreen({ mode = "maximized" }))

-- Join groups
bind({ "ALT", "H" }, hl.dsp.window.move({ into_group = true, direction = "l" }))
bind({ "ALT", "J" }, hl.dsp.window.move({ into_group = true, direction = "r" }))
bind({ "ALT", "K" }, hl.dsp.window.move({ into_group = true, direction = "u" }))
bind({ "ALT", "L" }, hl.dsp.window.move({ into_group = true, direction = "d" }))

-- Window navigation for grouped windows
bind({ "CTRL", "H" }, hl.dsp.group.prev())
bind({ "CTRL", "L" }, hl.dsp.group.next())

-- Scroll through grouped windows
bind({ "ALT", "mouse_down" }, hl.dsp.group.next())
bind({ "ALT", "mouse_up" }, hl.dsp.group.prev())

-- Workspace navigation
bind({ "TAB" }, hl.dsp.focus({ workspace = "previous" }))

bind({ "mouse_down" }, hl.dsp.focus({ workspace = "e+1" }))
bind({ "mouse_up" }, hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mouse
bind({ "mouse:272" }, hl.dsp.window.drag(), { mouse = true })
bind({ "mouse:273" }, hl.dsp.window.resize(), { mouse = true })

-- Captures
bind({ "SHIFT", "P" }, hl.dsp.exec_cmd("screenshot fullscreen"))
bind({ "CTRL", "S" }, hl.dsp.exec_cmd("screenshot"))
bind({ "SHIFT", "C" }, hl.dsp.exec_cmd("hyprpicker -a"), { description = "Color picker" })

-- Screen recording
bind({ "SHIFT", "R" }, hl.dsp.exec_cmd("save-replay"))
bind({ "CTRL", "R" }, hl.dsp.exec_cmd("toggle-recording"))

-- Copy/paste
bind({ "C" }, hl.dsp.send_shortcut({ mods = "CTRL", key = "Insert" }))
bind({ "V" }, hl.dsp.send_shortcut({ mods = "SHIFT", key = "Insert" }))
bind({ "X" }, hl.dsp.send_shortcut({ mods = "CTRL", key = "X" }))
bind({ "CTRL", "V" }, hl.dsp.exec_cmd("walker -m clipboard"))

-- Focus movement
bind({ "h" }, hl.dsp.focus({ direction = "l" }))
bind({ "l" }, hl.dsp.focus({ direction = "r" }))
bind({ "k" }, hl.dsp.focus({ direction = "u" }))
bind({ "j" }, hl.dsp.focus({ direction = "d" }))

-- Window movement
bind({ "SHIFT", "h" }, hl.dsp.window.swap({ direction = "l" }))
bind({ "SHIFT", "l" }, hl.dsp.window.swap({ direction = "r" }))
bind({ "SHIFT", "k" }, hl.dsp.window.swap({ direction = "u" }))
bind({ "SHIFT", "j" }, hl.dsp.window.swap({ direction = "d" }))

-- Move workspaces between monitors
bind({ "SHIFT", "ALT", "H" }, hl.dsp.workspace.move({ monitor = "l" }))
bind({ "SHIFT", "ALT", "L" }, hl.dsp.workspace.move({ monitor = "r" }))
bind({ "SHIFT", "ALT", "K" }, hl.dsp.workspace.move({ monitor = "u" }))
bind({ "SHIFT", "ALT", "J" }, hl.dsp.workspace.move({ monitor = "d" }))

-- Switch workspaces 1-9 and 10
for i = 1, 10 do
    local key = "code:" .. tostring(i + 9)
    bind({ key }, hl.dsp.focus({ workspace = i }))
    bind({ "SHIFT", key }, hl.dsp.window.move({ workspace = i }))
end

bind({ "G" }, hl.dsp.focus({ workspace = "name:gaming" }))
bind({ "ALT", "G" }, hl.dsp.window.move({ workspace = "name:gaming" }))

bind({ "D" }, hl.dsp.workspace.toggle_special("discord"))
bind({ "SHIFT", "D" }, hl.dsp.window.move({ workspace = "special:discord" }))

-- Volume
hl.bind(
    "XF86AudioRaiseVolume",
    hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true }
)
hl.bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true }
)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })

-- Media
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
bind({ "XF86AudioPlay" }, hl.dsp.exec_cmd("launch-or-focus-tui switch-audio"))

bind({ "CTRL", "Z" }, function()
    local zoom = hl.get_config("cursor.zoom_factor") or 1
    hl.config({ cursor = { zoom_factor = zoom + 1 } })
end, { description = "Zoom in" })

bind({ "CTRL", "ALT", "Z" }, function()
    hl.config({ cursor = { zoom_factor = 1 } })
end, { description = "Reset zoom" })
