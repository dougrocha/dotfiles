return {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {
        jump = { nohlsearch = true },
        search = {
            exclude = {
                'flash_prompt',
                'qf',
                function(win)
                    -- Floating windows from bqf.
                    if vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win)):match('BqfPreview') then return true end

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
}
