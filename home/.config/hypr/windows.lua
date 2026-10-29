hl.layer_rule({ match = { namespace = "qs.notification_overlay" }, no_anim = true })

-- grim runs as soon as the picker closes, so a fade-out would land in the capture
hl.layer_rule({ match = { namespace = "^(qs\\.screenshot_overlay.*|selection)$" }, no_anim = true })

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
hl.window_rule({ match = { class = ".*" }, tag = "+default-opacity" })

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

-- Apps that ask to be activated while they load; events.lua turns activation back on once they settle
hl.window_rule({
    name = "quiet-launch",
    match = { tag = "quiet-launch" },
    focus_on_activate = false,
})

-- Floating window tag for specific apps
hl.window_rule({
    match = { class = "^org\\.arsene\\.(wiremix|bluetui|switch-audio|btop|kura)$" },
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

-- Screenshot markup opens above the current workspace.
hl.window_rule({
    name = "screenshot-markup",
    match = { class = "^org\\.quickshell$", title = "^Screenshot Markup$" },
    float = true,
    center = true,
    opacity = "1 1",
})

hl.window_rule({
    -- Screenshot save-location picker (portal-backed Zenity dialog).
    name = "screenshot-save-location",
    match = {
        class = "^xdg-desktop-portal-gtk$",
        title = "^Save Screenshot To$",
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

-- Super+F on a browser: Quickshell floats it over the whole screen and moves it below the bar when the bar shows
hl.window_rule({
    name = "qs-fullscreen",
    match = { tag = "qs-fullscreen" },
    border_size = 0,
    rounding = 0,
    opacity = "1 1",
})
