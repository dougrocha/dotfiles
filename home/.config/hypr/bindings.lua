local mainMod = "SUPER"

-- Programs
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd("uwsm-app -- xdg-terminal-exec"))
hl.bind(mainMod .. " + W", hl.dsp.window.close())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("uwsm-app -- nautilus --new-window"))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("uwsm-app -- walker"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("uwsm-app -- $(xdg-settings get default-web-browser)"))

hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:scratchpad" }))


-- Tiling
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + M", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + CTRL + F", hl.dsp.window.fullscreen_state({ internal = 0, client = 2 }))
hl.bind(mainMod .. " + ALT + F", hl.dsp.window.fullscreen({ mode = "maximized" }))

-- Join groups
hl.bind(mainMod .. " + ALT + H", hl.dsp.window.move({ into_group = true, direction = "l" }))
hl.bind(mainMod .. " + ALT + J", hl.dsp.window.move({ into_group = true, direction = "r" }))
hl.bind(mainMod .. " + ALT + K", hl.dsp.window.move({ into_group = true, direction = "u" }))
hl.bind(mainMod .. " + ALT + L", hl.dsp.window.move({ into_group = true, direction = "d" }))

-- Window navigation for grouped windows
hl.bind(mainMod .. " + CTRL + H", hl.dsp.group.prev())
hl.bind(mainMod .. " + CTRL + L", hl.dsp.group.next())

-- Scroll through grouped windows
hl.bind(mainMod .. " + ALT + mouse_down", hl.dsp.group.next())
hl.bind(mainMod .. " + ALT + mouse_up", hl.dsp.group.prev())

-- Workspace navigation
hl.bind(mainMod .. " + TAB", hl.dsp.focus({ workspace = "previous" }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Captures
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("screenshot fullscreen"))
hl.bind(mainMod .. " + CTRL + S", hl.dsp.exec_cmd("screenshot"))

-- Screen recording
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("save-replay"))
hl.bind(mainMod .. " + CTRL + R", hl.dsp.exec_cmd("toggle-recording"))

-- Copy/paste
hl.bind(mainMod .. " + C", hl.dsp.send_shortcut({ mods = "CTRL", key = "Insert" }))
hl.bind(mainMod .. " + V", hl.dsp.send_shortcut({ mods = "SHIFT", key = "Insert" }))
hl.bind(mainMod .. " + X", hl.dsp.send_shortcut({ mods = "CTRL", key = "X" }))
hl.bind(mainMod .. " + CTRL + V", hl.dsp.exec_cmd("walker -m clipboard"))

-- Focus movement
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "d" }))

-- Window movement
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.swap({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.swap({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.swap({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.swap({ direction = "d" }))

-- Move workspaces between monitors
hl.bind(mainMod .. " + SHIFT + ALT + H", hl.dsp.workspace.move({ monitor = "l" }))
hl.bind(mainMod .. " + SHIFT + ALT + L", hl.dsp.workspace.move({ monitor = "r" }))
hl.bind(mainMod .. " + SHIFT + ALT + K", hl.dsp.workspace.move({ monitor = "u" }))
hl.bind(mainMod .. " + SHIFT + ALT + J", hl.dsp.workspace.move({ monitor = "d" }))

-- Switch workspaces 1-9 and 10
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

hl.bind(mainMod .. " + G", hl.dsp.focus({ workspace = "name:gaming" }))
hl.bind(mainMod .. " + ALT + G", hl.dsp.window.move({ workspace = "name:gaming" }))

hl.bind(mainMod .. " + D", hl.dsp.workspace.toggle_special("discord"))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.window.move({ workspace = "special:discord" }))

-- Volume
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_INPUT@ toggle"))

-- Media
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))
hl.bind(mainMod .. " + XF86AudioPlay", hl.dsp.exec_cmd("launch-or-focus-tui switch-audio"))
