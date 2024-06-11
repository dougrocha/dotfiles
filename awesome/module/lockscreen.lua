local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")

local dpi = beautiful.xresources.apply_dpi

package.cpath = package.cpath .. ";/usr/lib/lua-pam/?.so;"

---@class LockScreenConfig
---@field blur_background boolean
---@field bg_path string|nil
local lock_screen_config = {
    blur_background = true,
    bg_path = nil,
}

-- lock_screen.init = function()
--     local pam = require("liblua_pam")
--
--     lock_screen.authenticate = function(password)
--         return pam.auth_current_user(password)
--     end
--
--     require("lockscreenn.lock_screen")
-- end
--
-- return lock_screen
