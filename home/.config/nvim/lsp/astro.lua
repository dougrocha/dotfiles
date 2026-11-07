---@type vim.lsp.Config
return {
    cmd = function(dispatchers, config)
        local cmd = require 'utils.local_bin'((config or {}).root_dir, 'astro-ls')
        return vim.lsp.rpc.start({ cmd, '--stdio' }, dispatchers)
    end,
    filetypes = { 'astro' },
    root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' },
    init_options = {
        typescript = {},
    },
    before_init = function(_, config)
        if config.init_options and config.init_options.typescript and not config.init_options.typescript.tsdk then
            local project_roots =
                vim.fs.find('node_modules', { path = config.root_dir, upward = true, limit = math.huge })
            for _, project_root in ipairs(project_roots) do
                local typescript_path = project_root .. '/typescript'
                local stat = vim.uv.fs_stat(typescript_path)
                if stat and stat.type == 'directory' then
                    config.init_options.typescript.tsdk = typescript_path .. '/lib'
                    return
                end
            end
        end
    end,
}
