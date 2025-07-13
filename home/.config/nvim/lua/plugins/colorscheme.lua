return {
    'catppuccin/nvim',
    lazy = false,
    priority = 1000,
    enabled = false,
    name = 'catppuccin',
    ---@module 'catppuccin'
    ---@type CatppuccinOptions
    opts = {
        flavour = 'mocha',
        integrations = {
            treesitter = true,
            blink_cmp = true,
            fzf = true,
            harpoon = true,
            native_lsp = {
                enabled = true,
                underlines = {
                    errors = { 'undercurl' },
                    hints = { 'undercurl' },
                    warnings = { 'undercurl' },
                    information = { 'undercurl' },
                },
            },
            overseer = true,
            snacks = {
                enabled = true,
            },
        },
        color_overrides = {
            mocha = {
                base = '#0E1419',
            },
        },
    },
    config = function(_, opts)
        require('catppuccin').setup(opts)

        vim.cmd.colorscheme 'catppuccin'
    end,
}
