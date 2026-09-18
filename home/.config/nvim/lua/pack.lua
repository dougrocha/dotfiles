local M = {}

---@class PluginSpec
---@field [1] string GitHub "user/repo" shorthand
---@field dir? string Local plugin path (e.g. '~/dev/myplugin'); skips vim.pack.add
---@field module_name? string Override module name for require/setup (defaults to repo name)
---@field opts? table|fun():table Options passed to require(module).setup(opts)
---@field on_setup? fun() Runs after opts setup with no args
---@field setup? false Set to false to skip require/setup (for deps or vimscript plugins)
---@field on_update? string|fun() Command string (runs in plugin dir) or function, fired when the plugin's commit changes (install or update)
---@field version? string Git ref (branch, tag, or commit) passed to vim.pack.add
---@field event? string|string[] Defer loading until this autocmd event fires (once)
---@field pattern? string|string[] Autocmd pattern passed alongside event (e.g. filetypes)

---@param path string
---@param on_update string|fun()
local function run_on_update(path, on_update)
    if type(on_update) == 'string' then
        vim.system(vim.split(on_update, ' '), { cwd = path })
    else
        vim.schedule(on_update)
    end
end

local update_hooks = {}
local pending_changes = {}
local function handle_change(data)
    if data.kind ~= 'install' and data.kind ~= 'update' then return end
    local name = data.spec.name
    local hook = update_hooks[name]
    if not hook then
        pending_changes[name] = data
        return
    end
    pending_changes[name] = nil
    vim.opt.runtimepath:append(data.path)
    run_on_update(data.path, hook)
end

vim.api.nvim_create_autocmd('PackChanged', {
    group = vim.api.nvim_create_augroup('DotfilesPackHooks', { clear = true }),
    callback = function(ev)
        handle_change(ev.data)
    end,
})

---@param plugins PluginSpec[]
local function configure(plugins)
    local sources = vim.iter(plugins)
        :filter(function(p) return not p.dir end)
        :map(function(p)
            local url = ('https://github.com/%s'):format(p[1])
            if p.version then
                return { src = url, version = p.version }
            end
            return url
        end)
        :totable()

    for _, p in ipairs(plugins) do
        if p.dir then vim.opt.runtimepath:prepend(vim.fn.expand(p.dir)) end
    end

    if #sources > 0 then vim.pack.add(sources) end

    for _, p in ipairs(plugins) do
        if p.setup ~= false then
            local name = p.module_name or p[1]:match('[^/]+$'):gsub('%.nvim$', '')
            local ok, mod = pcall(require, name)
            if ok and type(mod) == 'table' and type(mod.setup) == 'function' then
                local opts = type(p.opts) == 'function' and p.opts() or p.opts
                mod.setup(opts or {})
            end
        end

        if p.on_setup then p.on_setup() end
    end
end

---@param event vim.api.keyset.events|vim.api.keyset.events[]
---@param pattern? string|string[]
---@param plugins PluginSpec[]
local function add_on_event(event, pattern, plugins)
    vim.api.nvim_create_autocmd(event, {
        pattern = pattern,
        once = true,
        callback = function() configure(plugins) end,
    })
end

---@param plugins PluginSpec[]
function M.add(plugins)
    for _, p in ipairs(plugins) do
        if p.on_update and not p.dir then
            local name = p[1]:match('[^/]+$')
            update_hooks[name] = p.on_update
            if pending_changes[name] then handle_change(pending_changes[name]) end
        end
    end
    local event = plugins[1] and plugins[1].event
    local pattern = plugins[1] and plugins[1].pattern
    if event or pattern then
        add_on_event(event or 'FileType', pattern, plugins)
    else
        configure(plugins)
    end
end

return M
