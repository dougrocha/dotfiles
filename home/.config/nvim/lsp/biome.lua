---@type vim.lsp.Config
return {
    cmd = { 'biome', 'lsp-proxy' },
    root_markers = { 'biome.json' },
    filetypes = {
        'css',
        'javascript',
        'javascriptreact',
        'json',
        'typescript',
        'typescriptreact',
    },
    workspace_required = true,
}
