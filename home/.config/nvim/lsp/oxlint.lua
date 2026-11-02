-- Uses the project's own oxlint so the editor matches `bun run lint`.
---@type vim.lsp.Config
return {
    cmd = function(dispatchers, config)
        local cmd = 'oxlint'
        if (config or {}).root_dir then
            local local_cmd = vim.fs.joinpath(config.root_dir, 'node_modules/.bin/oxlint')
            if vim.fn.executable(local_cmd) == 1 then
                cmd = local_cmd
            end
        end
        return vim.lsp.rpc.start({ cmd, '--lsp' }, dispatchers)
    end,
    filetypes = {
        'javascript',
        'javascriptreact',
        'typescript',
        'typescriptreact',
        'vue',
        'svelte',
        'astro',
    },
    root_markers = { '.oxlintrc.json', 'oxlint.config.ts' },
    workspace_required = true,
}
