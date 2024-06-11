local awful = require("awful")

local volume_old = -1
local muted_old = -1

local function emit()
    awful.spawn.easy_async_with_shell(
        "wpctl get-volume @DEFAULT_AUDIO_SINK@",
        function(out)
            local match = out:match("(%d%.%d+)") or 0
            local volume = tonumber(string.match(match * 100, "(%d+)"))
            local muted = out:match("MUTED")

            if volume ~= volume_old or muted ~= muted_old then
                awesome.emit_signal("signal::volume", volume, muted)
                ---@diagnostic disable-next-line: cast-local-type
                volume_old = volume
                muted_old = muted
            end
        end
    )
end

emit()

local subscribe =
    [[ bash -c "LANG=C pactl subscribe 2> /dev/null | grep --line-buffered \"Event 'change' on sink\"" ]]

awful.spawn.easy_async(
    { "pkill", "--full", "--uid", os.getenv("USER"), "^pactl subscribe" },
    function()
        awful.spawn.with_line_callback(subscribe, {
            stdout = function()
                emit()
            end,
        })
    end
)

awesome.connect_signal("signal::volume::toggle_mute", function()
    awful.spawn.easy_async_with_shell(
        "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",
        function() end
    )
end)

awesome.connect_signal("signal::volume::down", function()
    awful.spawn.easy_async_with_shell(
        "wpctl set-volume @DEFAULT_AUDIO_SINK@ .05-",
        function() end
    )
end)

awesome.connect_signal("signal::volume::up", function()
    awful.spawn.easy_async_with_shell(
        "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05+ --limit 1.0",
        function() end
    )
end)
