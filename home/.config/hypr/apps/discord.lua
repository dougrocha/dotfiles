hl.window_rule({
    name = "discord",
    match = { class = "discord" },
    workspace = "special:discord silent",
    -- Discord asks to be activated once it finishes loading
    focus_on_activate = false,
    tag = "+skip-first-activation",
})
