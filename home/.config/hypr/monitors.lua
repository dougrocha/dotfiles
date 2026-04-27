hl.env("GDK_SCALE", "1")

hl.monitor({
    output = "DP-1",
    mode = "2560x1440@240",
    position = "0x0",
    scale = "1",
})

hl.monitor({
    output = "DP-2",
    mode = "2560x1440@155",
    position = "2560x0",
    scale = "1",
})

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})
