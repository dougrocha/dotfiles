return {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    ---@module 'conform'
    ---@type conform.setupOpts
    opts = {
        notify_on_error = false,
        notify_no_formatters = false,
        formatters_by_ft = {
            astro = { 'prettier' },
            c = { name = 'clangd', lsp_format = 'prefer' },
            cpp = { name = 'clangd', lsp_format = 'prefer' },
            cs = { 'csharpier' },
            css = { 'prettier' },
            go = { 'gopls', lsp_format = 'prefer' },
            javascript = { 'prettier', lsp_format = 'fallback' },
            javascriptreact = { 'prettier', lsp_format = 'fallback' },
            json = { 'prettier', lsp_format = 'fallback' },
            jsonc = { 'prettier', lsp_format = 'fallback' },
            lua = { 'stylua' },
            markdown = { 'prettier' },
            python = { 'ruff_format' },
            rust = { name = 'rust_analyzer', timeout_ms = 500, lsp_format = 'prefer' },
            svelte = { 'prettier' },
            toml = { 'taplo' },
            typescript = { 'prettier', lsp_format = 'fallback' },
            typescriptreact = { 'prettier', lsp_format = 'fallback' },
            ['_'] = { 'trim_whitespace', 'trim_newlines' },
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

        prettier = {
            -- Require prettier file to format
            require_cwd = true,
        },
    },
    init = function()
        vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
        vim.g.autoformat = true
    end,
}
