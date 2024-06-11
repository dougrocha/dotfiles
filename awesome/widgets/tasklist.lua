local awful = require("awful")
local wibox = require("wibox")

local create_tasklist = function(s)
    local tasklist = awful.widget.tasklist({
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
        widget_template = {
            {
                {
                    id = "text_role",
                    widget = wibox.widget.textbox,
                },
                valign = "center",
                halign = "center",
                widget = wibox.container.place,
            },
            id = "background_role",
            widget = wibox.container.background,
        },
        buttons = {
            awful.button({}, 1, function(c)
                c:activate({
                    context = "tasklist",
                    action = "toggle_minimization",
                })
            end),
        },
    })

    return tasklist
end

return create_tasklist
