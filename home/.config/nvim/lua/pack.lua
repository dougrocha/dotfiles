local M = {}

---@class PluginSpec
---@field [1] string GitHub "user/repo" shorthand
---@field dir? string Local plugin path (e.g. '~/dev/myplugin'); skips vim.pack.add
---@field module_name? string Override module name for require/setup (defaults to repo name)
---@field opts? table|fun():table Options passed to require(module).setup(opts)
---@field on_setup? fun(ev?: table) Runs after opts setup, with the triggering event for lazy plugins
---@field setup? false Set to false to skip require/setup (for deps or vimscript plugins)
---@field on_update? fun() Runs when the plugin is installed or updated
---@field version? string Git ref (branch, tag, or commit) passed to vim.pack.add
---@field init? fun() Runs at startup, before the plugin is loaded
---@field lazy? PluginLazy Defer loading until a trigger fires

---@class PluginLazy
---@field event? string|string[] Autocmd events that load the plugin
---@field cmd? string|string[] User commands that load the plugin, then rerun with their args

---@type table<string, fun()>
local update_hooks = {}

vim.api.nvim_create_autocmd('PackChanged', {
    group = vim.api.nvim_create_augroup('DotfilesPackHooks', { clear = true }),
    callback = function(ev)
        local data = ev.data
        local hook = update_hooks[data.spec.name]
        if hook and (data.kind == 'install' or data.kind == 'update') then
            -- Make the plugin's code available when it isn't loaded yet.
            vim.opt.runtimepath:append(data.path)
            vim.schedule(hook)
        end
    end,
})

---@param p PluginSpec
---@return string
local function module_name(p)
    return p.module_name or p[1]:match('[^/]+$'):gsub('%.nvim$', '')
end

---@param p PluginSpec
---@param ev? table
local function setup(p, ev)
    if p.setup ~= false then
        local ok, mod = pcall(require, module_name(p))
        if ok and type(mod) == 'table' and type(mod.setup) == 'function' then
            local opts = type(p.opts) == 'function' and p.opts() or p.opts
            mod.setup(opts or {})
        end
    end

    if p.on_setup then
        p.on_setup(ev)
    end
end

---@type table<string, true>
local added = {}

---@param p PluginSpec
---@return string|{src: string, version: string}
local function source(p)
    local url = ('https://github.com/%s'):format(p[1])
    return p.version and { src = url, version = p.version } or url
end

---@type table<string, fun(ev?: table)>
local lazy_modules = {}

-- Requiring a deferred plugin's module loads it first, so keymaps can call into it freely.
-- A searcher is used rather than package.preload because the plugin's own files require
-- that module while loading.
table.insert(package.loaders, 2, function(modname)
    local load = lazy_modules[modname]
    if load then
        load()
    end
end)

--- Install the plugin if needed and register triggers instead of loading it.
---@param p PluginSpec
local function defer(p)
    local lazy = p.lazy
    local name = p[1]:match '[^/]+$'
    local group = vim.api.nvim_create_augroup('DotfilesLazy/' .. name, { clear = true })
    local commands = vim.islist(lazy.cmd) and lazy.cmd or { lazy.cmd }
    local preload = module_name(p)
    local loaded = false

    local function load(ev)
        if loaded then
            return
        end
        loaded = true
        vim.api.nvim_clear_autocmds { group = group }
        for _, cmd in ipairs(commands) do
            pcall(vim.api.nvim_del_user_command, cmd)
        end
        lazy_modules[preload] = nil
        vim.cmd.packadd(name)
        setup(p, ev)
    end

    lazy_modules[preload] = load

    if lazy.event then
        vim.api.nvim_create_autocmd(lazy.event, { group = group, once = true, callback = load })
    end

    for _, cmd in ipairs(commands) do
        vim.api.nvim_create_user_command(cmd, function(args)
            load()
            vim.cmd { cmd = cmd, args = args.fargs, bang = args.bang, mods = args.smods }
        end, { nargs = '*', bang = true, complete = 'command' })
    end
end

---@param plugins PluginSpec[]
local function configure(plugins)
    for _, p in ipairs(plugins) do
        if p.dir then
            vim.opt.runtimepath:prepend(vim.fn.expand(p.dir))
        end
    end

    local eager, deferred = {}, {}
    for _, p in ipairs(plugins) do
        local url = not p.dir and ('https://github.com/%s'):format(p[1])
        if url and not added[url] then
            added[url] = true
            table.insert(p.lazy and deferred or eager, source(p))
        end
    end
    if #eager > 0 then
        vim.pack.add(eager)
    end
    if #deferred > 0 then
        vim.pack.add(deferred, { load = false })
    end

    for _, p in ipairs(plugins) do
        if p.init then
            p.init()
        end
        if p.lazy then
            defer(p)
        else
            setup(p)
        end
    end
end

---@param plugins PluginSpec[]
function M.add(plugins)
    for _, p in ipairs(plugins) do
        if p.on_update and not p.dir then
            update_hooks[p[1]:match '[^/]+$'] = p.on_update
        end
    end
    configure(plugins)
end

return M
