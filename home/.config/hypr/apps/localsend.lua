-- LocalSend floating window
hl.window_rule({
    match = {
        class = "org.localsend.localsend_app",
        title = "LocalSend",
    },
    tag = "+floating-window",
})
