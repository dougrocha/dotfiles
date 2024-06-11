local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")

local helpers = require("helpers")
local mod = require("mod")

local dpi = beautiful.xresources.apply_dpi

local create_menu = function(s)
    local menu = wibox.widget({
        screen = s,
        image = beautiful.awesome_icon,
        widget = wibox.widget.imagebox,
    })

    -- local menu_popup = helpers.create_popup({
    --     content_widget = {
    --         { text = "About this PC", widget = wibox.widget.textbox },
    --         { text = "Recent Items", widget = wibox.widget.textbox },
    --         { text = "Restart...", widget = wibox.widget.textbox },
    --         { text = "Shut Down...", widget = wibox.widget.textbox },
    --         { text = "Log Out", widget = wibox.widget.textbox },
    --     },
    -- })
    --
    -- menu:connect_signal("button::press", function()
    --     menu_popup:toggle()
    -- end)

    return menu
end

return create_menu

-- local menu = awful.menu({
--     items = {
--         {
--             "About this PC",
--             function()
--                 -- open wezterm with fastfetch
--             end,
--         },
--         {
--             "Recent Items",
--             function()
--                 -- get recent opened items
--             end,
--         },
--         { "Restart...", "sudo systemctl reboot" },
--         { "Shut Down...", "sudo systemctl poweroff" },
--         {
--             "Log Out",
--             function()
--                 awesome.quit()
--             end,
--         },
--     },
-- })
--
-- local menu_launcher =
--     awful.widget.launcher({ image = beautiful.awesome_icon, menu = menu })
