return {
    'stevearc/quicker.nvim',
    event = 'VeryLazy',
    ---@module "quicker"
    ---@type quicker.SetupOptions
    opts = {},
    keys = {
        {
            '<leader>xq',
            function()
                require('quicker').toggle()
            end,
            desc = 'Toggle quickfix',
        },
        {
            '<leader>xl',
            function()
                require('quicker').toggle { loclist = true }
            end,
            desc = 'Toggle loclist list',
        },
        {
            '<leader>xd',
            function()
                local quicker = require 'quicker'

                if quicker.is_open() then
                    quicker.close()
                else
                    vim.diagnostic.setqflist()
                end
            end,
            desc = 'Toggle diagnostics',
        },
        {
            '>',
            function()
                require('quicker').expand { before = 2, after = 2, add_to_existing = true }
            end,
            desc = 'Expand context',
        },
        {
            '<',
            function()
                require('quicker').collapse()
            end,
            desc = 'Collapse context',
        },
    },
}
