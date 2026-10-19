-- Cider window rules
hl.window_rule({
    name = "cider",
    match = { class = "cider" },
    workspace = "special:scratchpad silent",
    -- Cider asks to be activated while it loads
    focus_on_activate = false,
    tag = "+quiet-launch",
})
