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

-- Windows that ask to be activated while they load, keyed by address once their quiet period starts
local quiet_launches = {}

local function allow_activation_after_launch(window)
    local quiet = false
    for _, tag in ipairs(window.tags) do
        if tag:find("^quiet%-launch") then
            quiet = true
        end
    end
    local address = window.address
    if not quiet or quiet_launches[address] then
        return
    end
    quiet_launches[address] = true
    -- Discord asks again about a second after its window opens, so ignore activations for a few seconds
    hl.timer(function()
        hl.dispatch(hl.dsp.window.set_prop({ prop = "focus_on_activate", value = "1", window = "address:" .. address }))
    end, { timeout = 5000, type = "oneshot" })
end

hl.on("window.urgent", allow_activation_after_launch)
