local clangd = require 'utils.clangd'
local store = require 'utils.store'

---@class util
---@field clangd util.clangd
---@field store util.store
local M = {
    clangd = clangd,
    store = store,
}

return M
