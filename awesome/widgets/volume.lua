local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local wibox = require("wibox")

local dpi = beautiful.xresources.apply_dpi

local create_volume_widget = function()
    local volume_widget = wibox.widget({
        id = "icon",
        widget = wibox.widget.imagebox,
        resize = false,
        forced_width = dpi(24),
        forced_height = dpi(24),
        valign = "center",
        halign = "center",
        buttons = {
            awful.button({}, 1, function()
                awesome.emit_signal("signal::volume::toggle_mute")
            end),
            awful.button({}, 4, function()
                awesome.emit_signal("signal::volume::up")
            end),
            awful.button({}, 5, function()
                awesome.emit_signal("signal::volume::down")
            end),
        },
    })

    local muted = false
    local vol = 0

    awful.tooltip({
        objects = { volume_widget },
        timeout = 0.15,
        delay_show = 0.5,
        margin_leftright = dpi(12),
        margin_topbottom = dpi(8),
        preferred_positions = "bottom",
        preferred_alignments = "middle",
        mode = "outside",
        gaps = {
            top = dpi(4),
        },
        ontop = true,
        shape = gears.shape.octogon,
        timer_function = function()
            if muted then
                return "Muted"
            else
                return vol
            end
        end,
    })

    awesome.connect_signal("signal::volume", function(volume, mute)
        if mute then
            volume_widget:set_image(beautiful.volume_off)
            muted = true
        else
            muted = false
            if volume >= 65 then
                volume_widget:set_image(beautiful.volume_up)
            elseif volume >= 35 then
                volume_widget:set_image(beautiful.volume_down)
            elseif volume > 0 then
                volume_widget:set_image(beautiful.volume_mute)
            else
                volume_widget:set_image(beautiful.no_sound)
            end
        end

        vol = volume
    end)

    return volume_widget
end

return create_volume_widget
