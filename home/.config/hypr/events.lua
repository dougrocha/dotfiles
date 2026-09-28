hl.on("hyprland.start", function()
    -- Run as a dbus service so it only counts as started once its tray host (StatusNotifierWatcher) is up
    hl.exec_cmd("uwsm-app -t service -s s -u qs.service -p Type=dbus -p BusName=org.kde.StatusNotifierWatcher -p Restart=on-failure -- qs")
    hl.exec_cmd("uwsm-app -- elephant")
    hl.exec_cmd("uwsm-app -- walker --gapplication-service")
    -- Electron only looks for a tray host at startup, so order tray apps after qs.service
    hl.exec_cmd("uwsm-app -t service -p After=qs.service -- vesktop")
    hl.exec_cmd("uwsm-app -t service -p After=qs.service -- cider")
end)
