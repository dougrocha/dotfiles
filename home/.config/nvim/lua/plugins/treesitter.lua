return {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    opts = {
        langs = {
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
    },
    config = function(_, opts)
        local treesitter = require 'nvim-treesitter'
        treesitter.install {
            opts.langs,
        }

        local group = vim.api.nvim_create_augroup('dougrocha/treesitter', { clear = true })
        vim.api.nvim_create_autocmd('FileType', {
            group = group,
            pattern = opts.langs,
            callback = function(args)
                -- Enable highlighting for the buffer
                vim.treesitter.start(args.buf)

                -- Enable indentation for the buffer
                vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

                -- Enable fold
                vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
                vim.wo[0][0].foldmethod = 'expr'
            end,
        })
    end,
}
