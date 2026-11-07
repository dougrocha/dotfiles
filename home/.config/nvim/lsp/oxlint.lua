---@type vim.lsp.Config
return {
    cmd = function(dispatchers, config)
        local cmd = require 'utils.local_bin'((config or {}).root_dir, 'oxlint')
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
