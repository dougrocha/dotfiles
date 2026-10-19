hl.window_rule({
    name = "discord",
    match = { class = "discord" },
    workspace = "special:discord silent",
    -- Discord asks to be activated while it loads
    focus_on_activate = false,
    tag = "+quiet-launch",
})
