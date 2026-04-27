-- Browser opacity
hl.window_rule({
    match = { class = "((google-)?chrom(e|ium)|zen|chrome-.*)" },
    opacity = "1.0 0.97",
})

hl.window_rule({
    match = { class = "((google-)?chrom(e|ium)|zen|chrome-.*)" },
    content = "video",
    idle_inhibit = "always",
})
