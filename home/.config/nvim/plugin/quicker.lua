local add = require('pack').add

add {
    {
        'stevearc/quicker.nvim',
        ---@module "quicker"
        ---@type quicker.SetupOptions
        opts = {},
        on_setup = function()
            local quicker = require 'quicker'

            vim.keymap.set('n', '<leader>xq', function()
                quicker.toggle()
            end, { desc = 'Toggle quickfix' })

            vim.keymap.set('n', '<leader>xl', function()
                quicker.toggle { loclist = true }
            end, { desc = 'Toggle loclist list' })

            vim.keymap.set('n', '<leader>xd', function()
                if quicker.is_open() then
                    quicker.close()
                else
                    vim.diagnostic.setqflist()
                end
            end, { desc = 'Toggle diagnostics' })

            vim.keymap.set('n', '>', function()
                quicker.expand { before = 2, after = 2, add_to_existing = true }
            end, { desc = 'Expand context' })

            vim.keymap.set('n', '<', function()
                quicker.collapse()
            end, { desc = 'Collapse context' })
        end,
    },
}
