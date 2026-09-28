-- Cider window rules
hl.window_rule({
    name = "cider",
    match = { class = "cider" },
    workspace = "special:scratchpad silent",
    -- Cider asks to be activated once it finishes loading, which would pull the scratchpad open
    focus_on_activate = false,
})
