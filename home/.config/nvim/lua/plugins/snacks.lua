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
    },
}
