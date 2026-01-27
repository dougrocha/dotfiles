return {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
        input = {
            enabled = true,
            win = {
                relative = 'cursor',
                title_pos = 'left',
            },
        },
        animate = {},
    },
    keys = {
        {
            '<leader>gg',
            function()
                require('snacks').lazygit()
            end,
            desc = 'LazyGit',
        },
        {
            '<leader>gl',
            function()
                require('snacks').lazygit.log()
            end,
            desc = 'LazyGit Log (cwd)',
        },
        {
            '<leader>gL',
            function()
                require('snacks').git.blame_line()
            end,
            desc = 'Git Blame Line',
        },
    },
}
