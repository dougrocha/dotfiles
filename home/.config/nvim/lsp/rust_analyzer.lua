---@type vim.lsp.Config
return {
    cmd = { 'rust-analyzer' },
    filetypes = { 'rust' },
    root_markers = { 'Cargo.toml' },
    capabilities = {
        experimental = {
            serverStatusNotification = true,
            commands = {
                commands = {
                    'rust-analyzer.showReferences',
                    'rust-analyzer.runSingle',
                    'rust-analyzer.debugSingle',
                },
            },
        },
    },
    ---@type lspconfig.settings.rust_analyzer
    settings = {
        ['rust-analyzer'] = {
            check = {
                command = 'clippy',
            },
            diagnostics = {
                enable = true,
            },
            inlayHints = {
                chainingHints = { enable = false },
            },
        },
    },
}
