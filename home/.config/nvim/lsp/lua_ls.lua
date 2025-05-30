---@type vim.lsp.Config
return {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = {
        '.luarc.json',
        '.luarc.jsonc',
        '.stylua.toml',
        'stylua.toml',
    },
    settings = {
        Lua = {
            completion = {
                callSnippet = 'Replace',
            },
            format = {
                enabled = false,
            },
            telemetry = { enable = false },
            hint = {
                enable = true,
                arrayIndex = 'Disable',
            },
            runtime = {
                version = 'LuaJIT',
            },
            workspace = {
                checkThirdParty = false,
            },
        },
    },
}
