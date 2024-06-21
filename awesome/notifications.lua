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

naughty.config.padding = dpi(8)
naughty.config.icon_formats = { "svg", "png", "jpg", "gif" }

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

    local header = n.app_name

    if n.app_name == "Cider" then
        header = "Now Playing"
    end

    local actions_template = nil

    if #n.actions > 0 then
        actions_template = wibox.widget({
            notification = n,
            base_layout = wibox.widget({
                spacing = dpi(6),
                fill_space = true,
                layout = wibox.layout.fixed.horizontal,
            }),
            widget_template = {
                {
                    {
                        id = "text_role",
                        font = "SF Pro Display 10",
                        valign = "center",
                        halign = "center",
                        widget = wibox.widget.textbox,
                    },
                    top = dpi(6),
                    bottom = dpi(6),
                    left = dpi(12),
                    right = dpi(12),
                    widget = wibox.container.margin,
                },
                bg = beautiful.button_bg,
                shape = gears.shape.rounded_rect,
                forced_height = dpi(24),
                widget = wibox.container.background,
            },
            style = { underline_normal = false, underline_selected = false },
            widget = naughty.list.actions,
        })
    end

    naughty.layout.box({
        notification = n,
        type = "notification",
        widget_template = {
            {
                {
                    {
                        {
                            {
                                markup = string.format(
                                    '<span foreground="%s" font="SF Pro Display Medium 12">%s</span>',
                                    beautiful.fg_focus,
                                    header
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
                                        actions_template,
                                        spacing = dpi(4),
                                        layout = wibox.layout.fixed.vertical,
                                    },
                                    padding = dpi(12),
                                    expand = "none",
                                    layout = wibox.layout.align.vertical,
                                },
                                spacing = dpi(8),
                                layout = wibox.layout.fixed.horizontal,
                            },
                            spacing = beautiful.notification_margin,
                            layout = wibox.layout.fixed.vertical,
                        },
                        margins = beautiful.notification_margin,
                        widget = wibox.container.margin,
                    },
                    strategy = "min",
                    width = dpi(160),
                    widget = wibox.container.constraint,
                },
                strategy = "max",
                width = beautiful.notification_max_width or dpi(500),
                widget = wibox.container.constraint,
            },
            id = "background",
            bg = beautiful.transparent,
            widget = naughty.container.background,
        },
    })
end)

naughty.notify({
    app_name = "APP_NAME",
    message = "TESTING MESSAGE",
    image = "~/Pictures/Wallpapers/Anime-Girl4.png",
    actions = {
        naughty.action({
            name = "TEST",
            icon_only = false,
        }),
    },
})
