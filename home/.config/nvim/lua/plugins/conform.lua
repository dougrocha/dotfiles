return {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    ---@module 'conform'
    ---@type conform.setupOpts
    opts = {
        notify_on_error = false,
        formatters_by_ft = {
            c = { name = 'clangd', lsp_format = 'prefer' },
            cpp = { name = 'clangd', lsp_format = 'prefer' },
            cs = { 'csharpier' },
            go = { 'gofumpt', 'goimports-reviser', 'golines' },
            lua = { 'stylua' },
            svelte = { 'prettierd' },
            astro = { 'prettierd' },
            css = { 'prettierd' },
            javascript = { 'prettierd' },
            javascriptreact = { 'prettierd' },
            typescript = { 'prettierd' },
            typescriptreact = { 'prettierd' },
            rust = { name = 'rust_analyzer', timeout_ms = 500, lsp_format = 'prefer' },
            json = { 'prettierd', lsp_format = 'prefer' },
            jsonc = { 'prettierd', lsp_format = 'prefer' },
            markdown = { 'prettierd' },
            toml = { 'taplo' },
            ['_'] = { 'trim_whitespace', 'trim_newlines' },
        },
        default_format_opts = {
            lsp_format = 'fallback',
        },
        format_on_save = function()
            -- Don't format when minifiles is open, since that triggers the "confirm without
            -- synchronization" message.
            if vim.g.minifiles_active then
                return nil
            end

            -- Stop if we disabled auto-formatting.
            if not vim.g.autoformat then
                return nil
            end

            return {}
        end,
    },
    init = function()
        vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
        vim.g.autoformat = true
    end,
}
