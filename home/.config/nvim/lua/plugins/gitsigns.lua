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
        current_line_blame = true,
        gh = true,
        on_attach = function(bufnr)
            local gs = package.loaded.gitsigns

            -- Register the leader group with miniclue.
            vim.b[bufnr].miniclue_config = {
                clues = {
                    { mode = 'n', keys = '<leader>g', desc = '+git' },
                    { mode = 'x', keys = '<leader>g', desc = '+git' },
                },
            }

            -- Mappings.
            ---@param lhs string
            ---@param rhs function
            ---@param desc string
            local function nmap(lhs, rhs, desc)
                vim.keymap.set('n', lhs, rhs, { desc = desc, buffer = bufnr })
            end
            nmap('[g', gs.prev_hunk, 'Previous hunk')
            nmap(']g', gs.next_hunk, 'Next hunk')
            nmap('<leader>gR', gs.reset_buffer, 'Reset buffer')
            nmap('<leader>gb', gs.blame_line, 'Blame line')
            nmap('<leader>gp', gs.preview_hunk, 'Preview hunk')
            nmap('<leader>gr', gs.reset_hunk, 'Reset hunk')
            nmap('<leader>gs', gs.stage_hunk, 'Stage hunk')
        end,
    },
}
