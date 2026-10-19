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

local function allow_activation_after_first(window)
    local skips_first = false
    for _, tag in ipairs(window.tags) do
        if tag:find("^skip%-first%-activation") then
            skips_first = true
        end
    end
    if not skips_first then
        return
    end
    local address = window.address
    -- Hyprland emits window.urgent before it checks focus_on_activate
    hl.timer(function()
        hl.dispatch(hl.dsp.window.set_prop({ prop = "focus_on_activate", value = "1", window = "address:" .. address }))
    end, { timeout = 1, type = "oneshot" })
end

hl.on("window.urgent", allow_activation_after_first)
