-- Suppress maximize requests from all apps
hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix XWayland dragging issues
hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

-- Hyprland-run positioning
hl.window_rule({
    name = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move = "20 monitor_h-120",
    float = true,
})

-- Tag rule: add default-opacity tag to all windows
hl.window_rule({
    match = { class = ".*" },
    tag = "+default-opacity",
})

-- Default opacity styling
hl.window_rule({
    name = "default-opacity",
    match = { tag = "default-opacity" },
    opacity = "0.97 0.9",
})

-- Floating window styling
hl.window_rule({
    name = "floating-window",
    match = { tag = "floating-window" },
    float = true,
    center = true,
    size = "875 600",
})

-- Floating window tag for specific apps
hl.window_rule({
    match = { class = "^org\\.arsene\\.(wiremix|bluetui|switch-audio|btop)$" },
    tag = "+floating-window",
})

-- Floating window tag for file dialogs
hl.window_rule({
    match = {
        class = "(xdg-desktop-portal-gtk|org.gnome.Nautilus)",
        title = "^(Open.*Files?|Open [F|f]older.*|Save.*Files?|Save.*As|Save|All Files|.*wants to [open|save].*|[C|c]hoose.*|[C|c]reate.*|[S|s]elect.*|Pick.*|File Upload.*|)$",
    },
    tag = "+floating-window",
})

-- No opacity for media apps
hl.window_rule({
    name = "no-opacity-on-media",
    match = { class = "^(mpv|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|legcord)$" },
    tag = "-default-opacity",
    opacity = "1 1",
})
