return {
    'nvim-treesitter/nvim-treesitter',
    version = false,
    build = ':TSUpdate',
    opts = {
        ensure_installed = {
            'bash',
            'cpp',
            'gitcommit',
            'json',
            'json5',
            'jsonc',
            'lua',
            'markdown',
            'markdown_inline',
            'regex',
            'rust',
            'toml',
            'tsx',
        },
        highlight = { enable = true },
        indent = { enable = true },
        folds = { enabled = true },
    },
    config = function(_, opts)
        require('nvim-treesitter.configs').setup(opts)
    end,
}
