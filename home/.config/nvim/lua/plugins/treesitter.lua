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
        highlight = { enable = true, additional_vim_regex_highlighting = false },
        indent = { enable = true },
    },
    config = function(_, opts)
        require('nvim-treesitter.configs').setup(opts)
    end,
}
