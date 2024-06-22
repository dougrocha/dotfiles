local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local naughty = require("naughty")
local ruled = require("ruled")
local wibox = require("wibox")

local player_ctl = require("signals.playerctl")

local config_dir = gears.filesystem.get_configuration_dir()
local themes_dir = config_dir .. "themes/"
local icons_dir = themes_dir .. "icons/"

local dpi = beautiful.xresources.apply_dpi

naughty.config.defaults.ontop = true
naughty.config.defaults.position = "top_right"
naughty.config.defaults.title = "System Notification"

naughty.config.padding = dpi(8)
naughty.config.icon_formats = { "svg", "png", "jpg", "gif" }

local get_player_actions = function()
    local skip_previous = naughty.action({
        icon_only = true,
        icon = icons_dir .. "skip_previous.svg",
    })
    local play_pause = naughty.action({
        icon_only = true,
        icon = icons_dir .. "play_pause.svg",
    })
    local skip_next = naughty.action({
        icon_only = true,
        icon = icons_dir .. "skip_next.svg",
    })

    skip_previous:connect_signal("invoked", function()
        player_ctl:previous("cider")
    end)
    play_pause:connect_signal("invoked", function()
        player_ctl:pause("cider")
    end)
    skip_next:connect_signal("invoked", function()
        player_ctl:next("cider")
    end)

    return { skip_previous, play_pause, skip_next }
end

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
            app_name = "Now Playing",
            append_actions = get_player_actions(),
            action_icons = true,
        },
    })
end)

naughty.connect_signal("request::display", function(n)
    local actions_template = nil

    if #n.actions > 0 then
        if n.action_icons then
            actions_template = wibox.widget({
                notification = n,
                base_layout = wibox.widget({
                    spacing = dpi(8),
                    layout = wibox.layout.flex.horizontal,
                }),
                widget_template = {
                    {
                        {
                            {
                                id = "icon_role",
                                widget = wibox.widget.imagebox,
                            },
                            widget = wibox.container.place,
                        },
                        top = dpi(2),
                        bottom = dpi(2),
                        left = dpi(6),
                        right = dpi(6),
                        widget = wibox.container.margin,
                    },
                    bg = beautiful.button_bg,
                    shape = gears.shape.rounded_rect,
                    widget = wibox.container.background,
                },
                style = { underline_normal = false, underline_selected = false },
                widget = naughty.list.actions,
            })
        else
            actions_template = wibox.widget({
                notification = n,
                base_layout = wibox.widget({
                    spacing = dpi(8),
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
                            ellipsize = "end",
                            widget = wibox.widget.textbox,
                        },
                        top = dpi(6),
                        bottom = dpi(6),
                        left = dpi(10),
                        right = dpi(10),
                        widget = wibox.container.margin,
                    },
                    bg = beautiful.button_bg,
                    shape = gears.shape.rounded_rect,
                    widget = wibox.container.background,
                },
                style = { underline_normal = false, underline_selected = false },
                widget = naughty.list.actions,
            })
        end
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
                                    n.app_name or ""
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
                                        {
                                            markup = string.format(
                                                '<span foreground="%s" font="SF Pro Display Bold 10">%s</span>',
                                                beautiful.fg_focus,
                                                n.title
                                            ),
                                            widget = wibox.widget.textbox,
                                        },
                                        naughty.widget.message,
                                        spacing = dpi(4),
                                        layout = wibox.layout.fixed.vertical,
                                    },
                                    right = dpi(16),
                                    widget = wibox.container.margin,
                                },
                                spacing = dpi(12),
                                layout = wibox.layout.fixed.horizontal,
                            },
                            actions_template,
                            spacing = beautiful.notification_spacing,
                            fill_space = true,
                            layout = wibox.layout.fixed.vertical,
                        },
                        margins = beautiful.notification_margin,
                        widget = wibox.container.margin,
                    },
                    strategy = "min",
                    width = dpi(240),
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

-- naughty.notify({
--     app_name = "Cider",
--     message = "TESTING's MESSAGE",
--     icon = beautiful.awesome_icon,
--     timeout = 0,
--     actions = {
--         naughty.action({
--             icon = icons_dir .. "skip_previous.svg",
--             icon_only = true,
--         }),
--         naughty.action({
--             icon = icons_dir .. "play_pause.svg",
--             icon_only = true,
--         }),
--         naughty.action({
--             icon = icons_dir .. "skip_next.svg",
--             icon_only = true,
--         }),
--     },
-- })
--
-- naughty.notify({
--     message = "TESTING's MESSAGE",
--     icon = beautiful.awesome_icon,
--     timeout = 0,
--     actions = {
--         naughty.action({
--             name = "TESTING",
--         }),
--         naughty.action({
--             name = "TESTING",
--         }),
--         naughty.action({
--             name = "TESTING",
--         }),
--     },
-- })
--
-- naughty.notify({
--     message = "TESTING's MESSAGE",
--     icon = beautiful.awesome_icon,
--     timeout = 0,
--     actions = {
--         naughty.action({
--             name = "TESTING",
--         }),
--     },
-- })
