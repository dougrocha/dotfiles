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
        lazygit = {
            config = {
                os = { editPreset = 'nvim-remote' },
                gui = {
                    -- set to an empty string "" to disable icons
                    nerdFontsVersion = '3',
                },
            },
        },
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
