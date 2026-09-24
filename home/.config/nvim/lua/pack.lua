local M = {}

---@class PluginSpec
---@field [1] string GitHub "user/repo" shorthand
---@field dir? string Local plugin path (e.g. '~/dev/myplugin'); skips vim.pack.add
---@field module_name? string Override module name for require/setup (defaults to repo name)
---@field opts? table|fun():table Options passed to require(module).setup(opts)
---@field on_setup? fun() Runs after opts setup with no args
---@field setup? false Set to false to skip require/setup (for deps or vimscript plugins)
---@field on_update? fun() Runs when the plugin is installed or updated
---@field version? string Git ref (branch, tag, or commit) passed to vim.pack.add

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
