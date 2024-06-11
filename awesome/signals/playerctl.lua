local awful = require("awful")

local playerctl = {}

function playerctl:status(player)
    if player ~= nil then
        awful.spawn.with_shell("playerctl --player=" .. player .. " status")
    else
        awful.spawn.with_shell("playerctl status")
    end
end

function playerctl:play(player)
    if player ~= nil then
        awful.spawn.with_shell("playerctl --player=" .. player .. " play")
    else
        awful.spawn.with_shell("playerctl play")
    end
end

function playerctl:pause(player)
    if player ~= nil then
        awful.spawn.with_shell("playerctl --player=" .. player .. " pause")
    else
        awful.spawn.with_shell("playerctl pause")
    end
end

function playerctl:stop(player)
    if player ~= nil then
        awful.spawn.with_shell("playerctl --player=" .. player .. " stop")
    else
        awful.spawn.with_shell("playerctl stop")
    end
end

function playerctl:previous(player)
    if player ~= nil then
        awful.spawn.with_shell("playerctl --player=" .. player .. " previous")
    else
        awful.spawn.with_shell("playerctl previous")
    end
end

function playerctl:next(player)
    if player ~= nil then
        awful.spawn.with_shell("playerctl --player=" .. player .. " next")
    else
        awful.spawn.with_shell("playerctl next")
    end
end

function playerctl:set_loop_status(loop_status, player)
    if player ~= nil then
        awful.spawn.with_shell(
            "playerctl --player=" .. player .. " loop " .. loop_status
        )
    else
        awful.spawn.with_shell("playerctl loop " .. loop_status)
    end
end

---Set track position
---@param position number Offset
---@param player string
function playerctl:set_position(position, player)
    if player ~= nil then
        awful.spawn.with_shell(
            "playerctl --player=" .. player .. " position " .. position
        )
    else
        awful.spawn.with_shell("playerctl position " .. position)
    end
end

---Set volume for player
---@param volume number Volume offset from [0.0, 1.0]
---@param player string
function playerctl:set_volume(volume, player)
    if player ~= nil then
        awful.spawn.with_shell(
            "playerctl --player=" .. player .. " volume " .. volume
        )
    else
        awful.spawn.with_shell("playerctl volume " .. volume)
    end
end

local function emit()
    awful.spawn.easy_async_with_shell(
        "playerctl metadata --format 'title_{{title}}album_{{album}}artist_{{artist}}art_url_{{mpris:artUrl}}player_name_{{playerName}}' && playerctl status",
        function(out)
            local title, album, artist, status, art_url, player_name

            title = out:match("title_(.*)album_") or ""
            album = out:match("album_(.*)artist_") or ""
            artist = out:match("artist_(.*)art_url_") or ""
            art_url = out:match("art_url_(.*)player_url") or ""
            player_name = out:match("player_name_(.*)") or ""

            if title == "" then
                title = "Not Playing"
            end
            if album == "" then
                album = "No Album"
            end
            if artist == "" then
                artist = "No Artist"
            end

            if out:match("Playing") then
                status = true
            else
                status = false
            end

            awesome.emit_signal(
                "signal::playerctl",
                title,
                album,
                artist,
                status,
                art_url,
                player_name
            )
        end
    )
end

emit()

local subscribe =
    [[ bash -c "playerctl metadata --format 'title_{{title}}album_{{album}}artist_{{artist}}art_url_{{mpris:artUrl}}player_name_{{playerName}}' -F & playerctl status -F" ]]

awful.spawn.easy_async(
    { "pkill", "--full", "--uid", os.getenv("USER"), "^playerctl" },
    function()
        awful.spawn.with_line_callback(subscribe, {
            stdout = function()
                emit()
            end,
        })
    end
)

return playerctl
