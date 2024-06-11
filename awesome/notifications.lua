local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local naughty = require("naughty")
local ruled = require("ruled")
local wibox = require("wibox")

local dpi = beautiful.xresources.apply_dpi

naughty.config.defaults.ontop = true
naughty.config.defaults.position = "top_right"
naughty.config.defaults.title = "System Notification"

ruled.notification.connect_signal("request::rules", function()
    -- Critical

    ruled.notification.append_rule({
        rule = { urgency = "critical" },
        properties = {
            bg = beautiful.bg_normal,
            fg = beautiful.fg_urgent,
            timeout = 0,
        },
    })

    -- Normal

    ruled.notification.append_rule({
        rule = { urgency = "normal" },
        properties = {
            bg = beautiful.bg_normal,
            fg = beautiful.fg_normal,
            timeout = 5,
        },
    })

    -- Low

    ruled.notification.append_rule({
        rule = { urgency = "low" },
        properties = {
            bg = beautiful.bg_normal,
            fg = beautiful.fg_normal,
            timeout = 5,
        },
    })

    -- Cider

    ruled.notification.append_rule({
        rule = { app_name = "Cider" },
        properties = {
            widget_template = {
                {
                    {
                        {
                            {
                                {
                                    markup = string.format(
                                        '<span foreground="%s">%s</span>',
                                        beautiful.fg_focus,
                                        "Now Playing"
                                    ),
                                    widget = wibox.widget.textbox,
                                },
                                {
                                    {
                                        {
                                            naughty.widget.icon,
                                            widget = wibox.container.place,
                                        },
                                        shape = gears.shape.rounded_rect,
                                        widget = wibox.container.background,
                                    },
                                    {
                                        {
                                            naughty.widget.title,
                                            naughty.widget.message,
                                            layout = wibox.layout.fixed.vertical,
                                        },
                                        spacing = dpi(6),
                                        expand = true,
                                        layout = wibox.layout.align.vertical,
                                    },
                                    spacing = dpi(12),
                                    layout = wibox.layout.fixed.horizontal,
                                },
                                spacing = dpi(12),
                                layout = wibox.layout.fixed.vertical,
                            },
                            top = dpi(8),
                            bottom = dpi(12),
                            left = dpi(12),
                            right = dpi(12),
                            widget = wibox.container.margin,
                        },
                        id = "min_size",
                        strategy = "min",
                        width = dpi(100),
                        widget = wibox.container.constraint,
                    },
                    id = "max_size",
                    strategy = "max",
                    width = dpi(500),
                    widget = wibox.container.constraint,
                },
                id = "background_role",
                widget = naughty.container.background,
            },
        },
    })
end)

naughty.connect_signal("request::display", function(n)
    n.title = string.format(
        '<span foreground="%s" font="SF Pro Display Bold 10">%s</span>',
        beautiful.fg_focus,
        n.title
    ) or ""
    n.message = string.format(
        '<span foreground="%s" font="SF Pro Display 10">%s</span>',
        beautiful.fg_normal,
        n.message
    ) or ""

    naughty.layout.box({ notification = n })
end)
