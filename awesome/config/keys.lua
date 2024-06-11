local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")

local mod = require("mod")

awful.mouse.append_global_mousebindings({
    --TODO: Create context menu
    -- awful.button({}, 3, function()
    --     main_menu:toggle()
    -- end),
    awful.button({}, 4, awful.tag.viewprev),
    awful.button({}, 5, awful.tag.viewnext),
})

awful.keyboard.append_global_keybindings({
    awful.key(
        { mod.super },
        "s",
        hotkeys_popup.show_help,
        { description = "show help", group = "awesome" }
    ),
    -- awful.key({ mod.super }, "w", function()
    --   mymainmenu:show()
    -- end, { description = "show main menu", group = "awesome" }),
    awful.key(
        { mod.super, mod.shift },
        "r",
        awesome.restart,
        { description = "reload awesome", group = "awesome" }
    ),
    awful.key(
        { mod.super, mod.shift },
        "q",
        awesome.quit,
        { description = "quit awesome", group = "awesome" }
    ),

    -- Prompt
    awful.key({ mod.super }, "space", function()
        awful.util.spawn("rofi -show drun")
    end, { description = "run rofi", group = "launcher" }),

    -- Applications
    --
    awful.key({ mod.super }, "b", function()
        awful.util.spawn("firefox")
    end, { description = "open firefox", group = "launcher" }),

    -- awful.key({ mod.super }, "x", function()
    --     awful.prompt.run({
    --         prompt = "Run Lua code: ",
    --         textbox = awful.screen.focused().mypromptbox.widget,
    --         exe_callback = awful.util.eval,
    --         history_path = awful.util.get_cache_dir() .. "/history_eval",
    --     })
    -- end, { description = "lua execute prompt", group = "awesome" }),

    -- Menubar
    -- awful.key({ mod.super }, "p", function()
    --   menubar.show()
    -- end, { description = "show the menubar", group = "launcher" })

    -- Screenshot

    awful.key({ mod.super }, "Delete", function()
        awesome.emit_signal("screenshot::full")
    end, { description = "full screen", group = "screenshot" }),

    awful.key({ mod.super, mod.ctrl }, "Delete", function()
        awesome.emit_signal("screenshot::fullwait")
    end, { description = "full screen delay", group = "screenshot" }),

    awful.key({ mod.super, mod.shift }, "Delete", function()
        awesome.emit_signal("screenshot::part")
    end, { description = "part screen", group = "screenshot" }),
})

awful.keyboard.append_global_keybindings({
    awful.key(
        { mod.super },
        "Left",
        awful.tag.viewprev,
        { description = "view previous", group = "tag" }
    ),
    awful.key(
        { mod.super },
        "Right",
        awful.tag.viewnext,
        { description = "view next", group = "tag" }
    ),
    awful.key(
        { mod.super },
        "Escape",
        awful.tag.history.restore,
        { description = "go back", group = "tag" }
    ),
})

awful.keyboard.append_global_keybindings({
    awful.key({ mod.super }, "j", function()
        awful.client.focus.bydirection("down")
    end, { description = "focux client down", group = "client" }),

    awful.key({ mod.super }, "k", function()
        awful.client.focus.bydirection("up")
    end, { description = "focus client up", group = "client" }),

    awful.key({ mod.super }, "h", function()
        awful.client.focus.bydirection("left")
    end, { description = "focux client left", group = "client" }),

    awful.key({ mod.super }, "l", function()
        awful.client.focus.bydirection("right")
    end, { description = "focux client right", group = "client" }),
})

awful.keyboard.append_global_keybindings({
    -- Layout manipulation
    awful.key({ mod.super, mod.shift }, "j", function()
        awful.client.swap.byidx(1)
    end, { description = "swap with next client by index", group = "client" }),

    awful.key(
        { mod.super, mod.shift },
        "k",
        function()
            awful.client.swap.byidx(-1)
        end,
        { description = "swap with previous client by index", group = "client" }
    ),

    awful.key({ mod.super, mod.ctrl }, "h", function()
        awful.screen.focus_relative(1)
    end, { description = "focus the next screen", group = "screen" }),

    awful.key({ mod.super, mod.ctrl }, "l", function()
        awful.screen.focus_relative(-1)
    end, { description = "focus the previous screen", group = "screen" }),

    awful.key(
        { mod.super },
        "u",
        awful.client.urgent.jumpto,
        { description = "jump to urgent client", group = "client" }
    ),

    awful.key({ mod.super }, "Tab", function()
        awful.client.focus.history.previous()
        if client.focus then
            client.focus:raise()
        end
    end, { description = "go back", group = "client" }),

    -- Standard program
    awful.key({ mod.super }, "Return", function()
        awful.spawn(user.terminal)
    end, { description = "open a terminal", group = "launcher" }),

    awful.key({ mod.super }, "k", function()
        awful.tag.incmwfact(0.05)
    end, { description = "increase master width factor", group = "layout" }),

    awful.key({ mod.super }, "j", function()
        awful.tag.incmwfact(-0.05)
    end, { description = "decrease master width factor", group = "layout" }),

    awful.key({ mod.super, mod.shift }, "h", function()
        awful.tag.incnmaster(1, nil, true)
    end, {
        description = "increase the number of master clients",
        group = "layout",
    }),

    awful.key({ mod.super, mod.shift }, "l", function()
        awful.tag.incnmaster(-1, nil, true)
    end, {
        description = "decrease the number of master clients",
        group = "layout",
    }),

    awful.key({ mod.super, mod.ctrl }, "h", function()
        awful.tag.incncol(1, nil, true)
    end, { description = "increase the number of columns", group = "layout" }),

    awful.key({ mod.super, mod.ctrl }, "l", function()
        awful.tag.incncol(-1, nil, true)
    end, { description = "decrease the number of columns", group = "layout" }),

    awful.key({ mod.super, mod.shift }, "space", function()
        awful.layout.inc(-1)
    end, { description = "select previous", group = "layout" }),

    awful.key({ mod.super, mod.ctrl }, "n", function()
        local c = awful.client.restore()
        -- Focus restored clienose
        if c then
            c:emit_signal(
                "request::activate",
                "key.unminimize",
                { raise = true }
            )
        end
    end, { description = "restore minimized", group = "client" }),
})

-- tag keybinds --

awful.keyboard.append_global_keybindings({
    -- View tag only.
    awful.key({
        modifiers = { mod.super },
        keygroup = "numrow",
        description = "only view tag",
        group = "tag",
        on_press = function(index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                tag:view_only()
            end
        end,
    }),
    -- Toggle tag display.
    awful.key({
        modifiers = { mod.super, mod.ctrl },
        keygroup = "numrow",
        description = "toggle tag",
        group = "tag",
        on_press = function(index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                awful.tag.viewtoggle(tag)
            end
        end,
    }),
    -- Move client to tag.
    awful.key({
        modifiers = { mod.super, mod.shift },
        keygroup = "numrow",
        description = "move focused client to tag",
        group = "tag",
        on_press = function(index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end,
    }),
    -- Toggle tag on focused client.
    awful.key({
        modifiers = { mod.super, mod.ctrl, mod.shift },
        keygroup = "numrow",
        description = "toggle focused client on tag",
        group = "tag",
        on_press = function(index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:toggle_tag(tag)
                end
            end
        end,
    }),
})

-- client keybinds --

client.connect_signal("request::default_mousebindings", function()
    awful.mouse.append_client_mousebindings({
        awful.button({}, 1, function(c)
            c:activate({ context = "mouse_click" })
        end),

        awful.button({ mod.super }, 1, function(c)
            c:activate({ context = "mouse_click", action = "mouse_move" })
        end),

        awful.button({ mod.super }, 3, function(c)
            c:activate({ context = "mouse_click", action = "mouse_resize" })
        end),
    })
end)

client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings({
        awful.key({ mod.super }, "f", function(c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end, { description = "toggle fullscreen", group = "client" }),

        awful.key({ mod.super }, "q", function(c)
            c:kill()
        end, { description = "close", group = "client" }),

        awful.key(
            { mod.super, mod.ctrl },
            "space",
            awful.client.floating.toggle,
            { description = "toggle floating", group = "client" }
        ),

        awful.key({ mod.super, mod.ctrl }, "Return", function(c)
            c:swap(awful.client.getmaster())
        end, { description = "move to master", group = "client" }),

        awful.key({ mod.super }, "o", function(c)
            c:move_to_screen()
        end, { description = "move to screen", group = "client" }),

        awful.key({ mod.super }, "t", function(c)
            c.ontop = not c.ontop
        end, { description = "toggle keep on top", group = "client" }),

        awful.key({ mod.super }, "n", function(c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end, { description = "minimize", group = "client" }),

        awful.key({ mod.super }, "m", function(c)
            c.maximized = not c.maximized
            c:raise()
        end, { description = "(un)maximize", group = "client" }),

        awful.key({ mod.super, mod.ctrl }, "m", function(c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end, {
            description = "(un)maximize vertically",
            group = "client",
        }),

        awful.key({ mod.super, mod.shift }, "m", function(c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end, {
            description = "(un)maximize horizontally",
            group = "client",
        }),
    })
end)
