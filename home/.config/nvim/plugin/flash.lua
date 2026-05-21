local add = require('pack').add

add {
    {
        'folke/flash.nvim',
        ---@type Flash.Config
        opts = {
            jump = { nohlsearch = true },
            prompt = {
                win_config = {
                    border = 'none',
                    -- Place the prompt above the statusline.
                    row = -3,
                },
            },
            search = {
                exclude = {
                    'flash_prompt',
                    'qf',
                    function(win)
                        -- Floating windows from bqf.
                        if vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win)):match 'BqfPreview' then
                            return true
                        end

                        -- Non-focusable windows.
                        return not vim.api.nvim_win_get_config(win).focusable
                    end,
                },
            },
            modes = {
                -- Enable flash when searching with ? or /
                search = { enabled = true },
            },
        },
        on_setup = function()
            local flash = require 'flash'
            vim.keymap.set({ 'n', 'x', 'o' }, 's', function()
                flash.jump()
            end, { desc = 'Flash' })
            vim.keymap.set('o', 'r', function()
                flash.remote()
            end, { desc = 'Remote Flash' })
            vim.keymap.set({ 'o', 'x' }, 'R', function()
                flash.treesitter_search()
            end, { desc = 'Treesitter Search' })
        end,
    },
}
