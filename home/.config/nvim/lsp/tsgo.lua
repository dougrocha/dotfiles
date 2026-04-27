---@type vim.lsp.Config
return {
    cmd = function(dispatchers, config)
        local cmd = 'tsgo'
        if (config or {}).root_dir then
            local local_cmd = vim.fs.joinpath(config.root_dir, 'node_modules/.bin', cmd)
            if vim.fn.executable(local_cmd) == 1 then
                cmd = local_cmd
            end
        end
        return vim.lsp.rpc.start({ cmd, '--lsp', '--stdio' }, dispatchers)
    end,
    filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    root_dir = function(bufnr, on_dir)
        local root_markers = { { 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lock' }, { '.git' } }

        local project_root = vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()

        on_dir(project_root)
    end,
}