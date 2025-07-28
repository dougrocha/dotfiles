local vertical_bar = require('icons').misc.vertical_bar
local dashed_bar = require('icons').misc.dashed_bar

return {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
        signs = {
            add = { text = vertical_bar },
            untracked = { text = vertical_bar },
            change = { text = vertical_bar },
            delete = { text = vertical_bar },
            topdelete = { text = vertical_bar },
            changedetele = { text = vertical_bar },
        },
        signs_staged = {
            add = { text = dashed_bar },
            untracked = { text = dashed_bar },
            change = { text = dashed_bar },
            delete = { text = dashed_bar },
            topdelete = { text = dashed_bar },
            changedetele = { text = dashed_bar },
        },
        on_attach = function(bufnr)
            -- on attach
        end,
    },
}
