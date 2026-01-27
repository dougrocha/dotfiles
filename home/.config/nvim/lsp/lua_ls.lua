---@type vim.lsp.Config
return {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = { '.luarc.json', '.luarc.jsonc' },
    settings = {
        Lua = {
            completion = { callSnippet = 'Replace' },
            format = { enabled = false },
            hint = {
                enable = true,
                arrayIndex = 'Disable',
                semiColon = 'Disable',
            },
            runtime = {
                version = 'LuaJIT',
            },
            workspace = {
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME,
                    '${3rd}/luv/library',
                },
            },
        },
    },
}
