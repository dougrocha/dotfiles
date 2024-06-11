local awful = require("awful")
local ruled = require("ruled")

local screen_width = awful.screen.focused().geometry.width
local screen_height = awful.screen.focused().geometry.height

ruled.client.connect_signal("request::rules", function()
    -- All clients will match this rule.
    ruled.client.append_rule({
        id = "global",
        rule = {},
        properties = {
            focus = awful.client.focus.filter,
            raise = true,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap
                + awful.placement.no_offscreen,
        },
    })

    -- Floating clients.
    ruled.client.append_rule({
        id = "floating",
        rule_any = {
            instance = {
                "Devtools",
            },
            class = {
                "Arandr",
                "Blueman-manager",
                "Lxappearance",
            },
            role = {
                "pop-up",
            },
        },
        properties = { floating = true },
    })

    -- Don't set titlebars to normal clients and dialogs
    ruled.client.append_rule({
        id = "titlebars",
        rule_any = { type = { "normal", "dialog" } },
        properties = { titlebars_enabled = false },
    })

    ruled.client.append_rule({
        rule_any = {
            class = { "discord", "Cider" },
        },
        properties = {
            tag = screen[1].tags[2],
        },
    })

    ruled.client.append_rule({
        rule_any = {
            class = {
                "feh",
            },
        },
        properties = {
            floating = true,
            width = screen_width * 0.7,
            height = screen_height * 0.75,
        },
        callback = function(c)
            awful.placement.centered(
                c,
                { honor_padding = true, honor_workarea = true }
            )
        end,
    })
end)

client.connect_signal("request::manage", function(c)
    if c.transient_for then
        awful.placement.centered(c, c.transient_for)
        awful.placement.no_offscreen(c)
    end
end)
