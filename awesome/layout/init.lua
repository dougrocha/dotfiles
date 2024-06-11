local menu_bar = require("layout.menu_bar")

screen.connect_signal("request::desktop_decoration", function(s)
    s.menu_bar = menu_bar(s)
end)
