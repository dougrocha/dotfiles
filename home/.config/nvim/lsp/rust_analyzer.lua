---@type vim.lsp.Config
return {
    cmd = { 'rust-analyzer' },
    filetypes = { 'rust' },
    root_markers = { 'Cargo.toml' },
    settings = {
        ['rust-analyzer'] = {
            inlayHints = {
                chainingHints = { enable = false },
            },
        },
    },
}
