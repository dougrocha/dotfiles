-- Small JSON files under stdpath('data'), for state that should survive restarts.

---@class util.store
local M = {}

---@param name string
---@return string
local function path(name)
    return vim.fs.joinpath(vim.fn.stdpath 'data', name .. '.json')
end

--- Read `<data>/<name>.json`. Returns an empty table if it's missing or invalid.
---@param name string
---@return table
function M.read(name)
    local file = io.open(path(name), 'r')
    if not file then
        return {}
    end
    local ok, data = pcall(vim.json.decode, file:read '*a', { luanil = { object = true, array = true } })
    file:close()
    return ok and type(data) == 'table' and data or {}
end

---@param name string
---@param data table
function M.write(name, data)
    vim.fn.mkdir(vim.fn.stdpath 'data', 'p')
    local file = assert(io.open(path(name), 'w'))
    file:write(vim.json.encode(data))
    file:close()
end

--- Read the table, let `fn` change it in place, then write it back.
---@param name string
---@param fn fun(data: table)
function M.update(name, fn)
    local data = M.read(name)
    fn(data)
    M.write(name, data)
end

return M
