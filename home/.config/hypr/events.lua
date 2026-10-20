hl.on("hyprland.start", function()
    -- Run as a dbus service so it only counts as started once its tray host (StatusNotifierWatcher) is up
    hl.exec_cmd("uwsm-app -t service -s s -u qs.service -p Type=dbus -p BusName=org.kde.StatusNotifierWatcher -p Restart=on-failure -- qs")
    hl.exec_cmd("uwsm-app -- elephant")
    hl.exec_cmd("uwsm-app -- walker --gapplication-service")
    -- Electron only looks for a tray host at startup, so wait for qs's watcher; After= alone races qs's start job
    local wait_tray = "-p 'ExecStartPre=/usr/bin/gdbus wait --session --timeout 30 org.kde.StatusNotifierWatcher'"
    hl.exec_cmd("uwsm-app -t service " .. wait_tray .. " -- discord")
    hl.exec_cmd("uwsm-app -t service " .. wait_tray .. " -- cider")
end)

local function has_tag(window, name)
    for _, tag in ipairs(window.tags) do
        -- Tags set by a rule carry a trailing *
        if tag == name or tag == name .. "*" then
            return true
        end
    end
    return false
end

-- Quiet-launch windows ignore activation while they load: for up to 30s after they open, and
-- until 5s after their latest request, since Discord asks more than once and Cider asks late
local quiet_windows = {}
local quiet_generation = 0

local function stay_quiet(selector, timeout)
    quiet_generation = quiet_generation + 1
    local generation = quiet_generation
    quiet_windows[selector] = generation
    hl.timer(function()
        if quiet_windows[selector] == generation then
            quiet_windows[selector] = nil
            hl.dispatch(hl.dsp.window.set_prop({ prop = "focus_on_activate", value = "1", window = selector }))
        end
    end, { timeout = timeout, type = "oneshot" })
end

hl.on("window.open", function(window)
    if has_tag(window, "quiet-launch") then
        stay_quiet("address:" .. window.address, 30000)
    end
end)

hl.on("window.urgent", function(window)
    local selector = "address:" .. window.address
    if quiet_windows[selector] then
        stay_quiet(selector, 5000)
    end
end)
