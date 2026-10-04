hl.on("hyprland.start", function()
    -- Run as a dbus service so it only counts as started once its tray host (StatusNotifierWatcher) is up
    hl.exec_cmd("uwsm-app -t service -s s -u qs.service -p Type=dbus -p BusName=org.kde.StatusNotifierWatcher -p Restart=on-failure -- qs")
    hl.exec_cmd("uwsm-app -- elephant")
    hl.exec_cmd("uwsm-app -- walker --gapplication-service")
    -- Electron only looks for a tray host at startup, so wait for qs's watcher; After= alone races qs's start job
    local wait_tray = "-p 'ExecStartPre=/usr/bin/gdbus wait --session --timeout 30 org.kde.StatusNotifierWatcher'"
    hl.exec_cmd("uwsm-app -t service " .. wait_tray .. " -- vesktop")
    hl.exec_cmd("uwsm-app -t service " .. wait_tray .. " -- cider")
end)
