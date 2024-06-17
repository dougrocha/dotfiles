-- Thank you to grumph
-- @see https://bitbucket.org/grumph/home_config/src/master/.config/awesome/helpers/click_to_hide.lua

local awful = require("awful")
local gears = require("gears")

local click_to_hide = require("helpers.click_to_hide")

local function create_popup(args)
    local config = gears.table.join({
        ontop = true,
        visible = false,
        hide_on_right_click = false,
        hide_on_click_anywhere = true,
        hide_on_left_click = false, -- only used when hide_on_click_anywhere is set
        widget = {},
        content_widget = nil, -- for initialization with a widget, will not be re-calculated
        content_function = nil, -- for initialization with a function, will be run every time the popup is shown
        preferred_anchors = { "middle", "front", "back" },
    }, args)

    assert(config.content_widget or config.content_function)

    local popup = awful.popup(config)

    if config.content_widget then
        popup:setup(config.content_widget)
    end

    if config.hide_on_click_anywhere then
        click_to_hide(popup, nil, not config.hide_on_left_click)
    end

    --- Mechanism to disallow popup to toggle too often.
    --  This avoids multiple toogles problem caused by hide_on_click
    local can_toggle = true
    local toggle_lock_timer = gears.timer({
        timeout = 0.1,
        single_shot = true,
        callback = function()
            can_toggle = true
        end,
    })

    popup:connect_signal("property::visible", function()
        can_toggle = false
        toggle_lock_timer:again()
    end)

    --- Toogles the popup
    function popup:toggle(force)
        if can_toggle then
            if force == false or (force == nil and self.visible) then
                self.visible = false
            else
                if config.content_function then
                    self:setup(config.content_function())
                end
                self:move_next_to(mouse.current_widget_geometry)
                self.visible = true
            end
        end
    end

    return popup
end

return create_popup
