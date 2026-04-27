-- Picture-in-Picture styling
hl.window_rule({
    name = "picture-in-picture",
    match = { title = "Picture.?in.?[Pp]icture" },
    tag = "-default-opacity",
    float = true,
    pin = true,
    workspace = 1,
    size = "600 338",
    keep_aspect_ratio = true,
    border_size = 0,
    opacity = "1 1",
    move = "(monitor_w-window_w-40) (monitor_h*0.04)",
})
