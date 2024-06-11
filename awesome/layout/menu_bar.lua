local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")

local mod = require("mod")

local dpi = beautiful.xresources.apply_dpi

local menu_bar = function(s)
    local bar = awful.wibar({
        screen = s,
    })

    s.layout_widget = awful.widget.layoutbox({
        screen = s,
        buttons = {
            awful.button({}, 1, function()
                awful.layout.inc(1)
            end),
            awful.button({}, 3, function()
                awful.layout.inc(-1)
            end),
            awful.button({}, 4, function()
                awful.layout.inc(1)
            end),
            awful.button({}, 5, function()
                awful.layout.inc(-1)
            end),
        },
    })

    -- Create a taglist widget
    s.taglist = awful.widget.taglist({
        screen = s,
        filter = awful.widget.taglist.filter.all,
        buttons = {
            awful.button({}, 1, function(t)
                t:view_only()
            end),
            awful.button({ mod.super }, 1, function(t)
                if client.focus then
                    client.focus:move_to_tag(t)
                end
            end),
            awful.button({}, 3, awful.tag.viewtoggle),
            awful.button({ mod.super }, 3, function(t)
                if client.focus then
                    client.focus:toggle_tag(t)
                end
            end),
            awful.button({}, 4, function(t)
                awful.tag.viewprev(t.screen)
            end),
            awful.button({}, 5, function(t)
                awful.tag.viewnext(t.screen)
            end),
        },
    })

    -- Create a tasklist widget
    s.tasklist = require("widgets.tasklist")(s)

    if s == screen[1] then
        s.clock = wibox.widget.textclock("%a %b %d %I:%M %P")
        s.volume_widget = require("widgets.volume")()
        s.menu = require("widgets.menu")(s)

        bar:setup({
            {
                {
                    s.menu,
                    s.taglist,
                    spacing = dpi(8),
                    layout = wibox.layout.fixed.horizontal,
                },
                margins = dpi(6),
                widget = wibox.container.margin,
            },
            s.tasklist,
            {
                {
                    s.volume_widget,
                    s.clock,
                    s.layout_widget,
                    spacing = dpi(12),
                    layout = wibox.layout.fixed.horizontal,
                },
                margins = dpi(6),
                widget = wibox.container.margin,
            },
            layout = wibox.layout.align.horizontal,
        })
    else
        bar:setup({
            {
                s.taglist,
                margins = dpi(6),
                widget = wibox.container.margin,
            },
            s.tasklist,
            {
                {
                    s.layout_widget,
                    spacing = dpi(8),
                    layout = wibox.layout.fixed.horizontal,
                },
                margins = dpi(6),
                widget = wibox.container.margin,
            },
            layout = wibox.layout.align.horizontal,
        })
    end

    return bar
end

return menu_bar
