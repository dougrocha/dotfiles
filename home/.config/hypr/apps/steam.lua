-- Steam window rules
hl.window_rule({
    name = "steam",
    match = { class = "steam" },
    float = true,
    center = true,
    tag = "-default-opacity",
    opacity = "1 1",
    idle_inhibit = "fullscreen",
})

hl.window_rule({
    name = "steam-main",
    match = {
        class = "steam",
        title = "Steam",
    },
    size = "1300 820",
})

hl.window_rule({
    name = "steam-friends",
    match = {
        class = "steam",
        title = "Friends List",
    },
    size = "460 800",
})

hl.window_rule({
    name = "steam-game",
    match = { class = "steam_app_.*" },
    workspace = "name:gaming",
    fullscreen = true,
    tag = "+floating-window",
    opacity = "1 1",
    idle_inhibit = "fullscreen",
})
