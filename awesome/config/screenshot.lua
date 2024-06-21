local awful = require("awful")
local naughty = require("naughty")

local function screenshot(args, time)
    local file = os.date("%F-%H%M%S") .. ".png"
    local tmp = "/tmp/" .. file

    awful.spawn.easy_async_with_shell(
        "sleep " .. time .. " && maim " .. args .. " " .. tmp,
        function()
            awful.spawn.easy_async_with_shell(
                "[ -e '" .. tmp .. "' ] && echo exists",
                function(output)
                    if output:match("%w+") then
                        awful.spawn.easy_async_with_shell(
                            "cat " .. tmp .. " | xclip -se c -t image/png -i"
                        )
                        awful.spawn.easy_async_with_shell(
                            "cp " .. tmp .. " " .. user.screenshot_dir
                        )
                        awful.spawn.easy_async_with_shell("rm " .. tmp)

                        local open_image = naughty.action({
                            name = "Open",
                            icon_only = false,
                        })

                        local open_folder = naughty.action({
                            name = "Open Folder",
                            icon_only = false,
                        })

                        local delete_image = naughty.action({
                            name = "Delete",
                            icon_only = false,
                        })

                        local path = user.screenshot_dir .. file
                        open_image:connect_signal("invoked", function()
                            awful.spawn.easy_async_with_shell(
                                "xdg-open " .. path,
                                function() end
                            )
                        end)

                        open_folder:connect_signal("invoked", function()
                            awful.spawn.easy_async_with_shell(
                                "xdg-open " .. user.screenshot_dir,
                                function() end
                            )
                        end)

                        delete_image:connect_signal("invoked", function()
                            awful.spawn.easy_async_with_shell(
                                "rm " .. path,
                                function() end
                            )
                        end)

                        naughty.notification({
                            app_name = "Screenshot",
                            title = "Snap!",
                            text = "Saved to " .. user.screenshot_dir,
                            actions = { open_image, open_folder, delete_image },
                        })
                    else
                        naughty.notification({
                            app_name = "Screenshot",
                            title = "Snap!",
                            text = "Cancelled",
                        })
                    end
                end
            )
        end
    )
end

awesome.connect_signal("screenshot::full", function()
    screenshot("-u", "0")
end)

awesome.connect_signal("screenshot::fullwait", function()
    screenshot("-u", "5")
end)

awesome.connect_signal("screenshot::part", function()
    screenshot("-s -u", "0")
end)
