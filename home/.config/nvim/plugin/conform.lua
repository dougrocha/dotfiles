local add = require('pack').add

add {
    {
        'stevearc/conform.nvim',
        lazy = { event = 'BufWritePre', cmd = 'ConformInfo' },
        ---@module 'conform'
        ---@type conform.setupOpts
        opts = {
            notify_on_error = false,
            notify_no_formatters = false,
            formatters = {
                odinfmt = {
                    command = 'odinfmt',
                    args = { '-stdin' },
                    stdin = true,
                },
                prettier = {
                    -- Only run prettier in projects that have a prettier config.
                    require_cwd = true,
                },
            },
            formatters_by_ft = {
                c = { lsp_format = 'prefer' },
                cpp = { lsp_format = 'prefer' },
                css = { 'prettier' },
                go = { lsp_format = 'prefer' },
                html = { 'prettier' },
                javascript = { 'prettier', lsp_format = 'fallback' },
                javascriptreact = { 'prettier', lsp_format = 'fallback' },
                json = { 'prettier', lsp_format = 'fallback' },
                jsonc = { 'prettier', lsp_format = 'fallback' },
                lua = { 'stylua' },
                odin = { 'odinfmt' },
                markdown = { 'prettier' },
                objc = { lsp_format = 'prefer' },
                objcpp = { lsp_format = 'prefer' },
                rust = { lsp_format = 'prefer' },
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
        on_setup = function(ev)
            -- Conform loads in the middle of the first BufWritePre, which skips its own handler.
            if ev and ev.event == 'BufWritePre' then
                vim.api.nvim_exec_autocmds('BufWritePre', { group = 'Conform', buffer = ev.buf, modeline = false })
            end
        end,
    },
}
