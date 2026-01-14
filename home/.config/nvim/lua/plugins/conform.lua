return {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    ---@module 'conform'
    ---@type conform.setupOpts
    opts = {
        notify_on_error = false,
        formatters_by_ft = {
            astro = { 'prettierd' },
            c = { name = 'clangd', lsp_format = 'prefer' },
            cpp = { name = 'clangd', lsp_format = 'prefer' },
            cs = { 'csharpier' },
            css = { 'prettierd' },
            go = { 'gopls', lsp_format = 'prefer' },
            javascript = { 'prettierd', lsp_format = 'fallback' },
            javascriptreact = { 'prettierd', lsp_format = 'fallback' },
            json = { 'prettierd', lsp_format = 'fallback' },
            jsonc = { 'prettierd', lsp_format = 'fallback' },
            lua = { 'stylua' },
            markdown = { 'prettierd' },
            python = { 'ruff_format' },
            rust = { name = 'rust_analyzer', timeout_ms = 500, lsp_format = 'prefer' },
            svelte = { 'prettierd' },
            toml = { 'taplo' },
            typescript = { 'prettierd', lsp_format = 'fallback' },
            typescriptreact = { 'prettierd', lsp_format = 'fallback' },
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
