local add = require('pack').add

add {
    { 'nvim-lua/plenary.nvim', setup = false },
    {
        'ThePrimeagen/harpoon',
        version = 'harpoon2',
        setup = false,
        on_setup = function()
            local harpoon = require 'harpoon'

            harpoon:setup {
                settings = {
                    save_on_toggle = true,
                },
            }

            vim.keymap.set('n', '<leader>h', function()
                harpoon:list():add()
                vim.notify('󱡅 marked ' .. vim.fn.expand '%:t', vim.log.levels.INFO)
            end, { desc = 'Harpoon file' })

            for i = 1, 5 do
                vim.keymap.set('n', '<Space>' .. i, function()
                    harpoon:list():select(i)
                end, { desc = 'Select harpoon item ' .. i })
            end

            vim.keymap.set('n', '<C-e>', function()
                harpoon.ui:toggle_quick_menu(harpoon:list())
            end, { desc = 'Toggle harpoon menu' })
        end,
    },
}
