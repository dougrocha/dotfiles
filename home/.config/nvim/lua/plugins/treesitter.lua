return {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    opts = {
        langs = {
            'bash',
            'cpp',
            'gitcommit',
            'java',
            'json',
            'json5',
            'lua',
            'markdown',
            'markdown_inline',
            'regex',
            'rust',
            'toml',
            'tsx',
            'typescript',
        },
    },
    config = function(_, opts)
        local treesitter = require 'nvim-treesitter'
        treesitter.install(opts.langs)

        local parser_to_filetype = {
            tsx = 'typescriptreact',
        }

        local patterns = {}
        for _, lang in ipairs(opts.langs) do
            table.insert(patterns, parser_to_filetype[lang] or lang)
        end

        local group = vim.api.nvim_create_augroup('dougrocha/treesitter', { clear = true })
        vim.api.nvim_create_autocmd('FileType', {
            group = group,
            pattern = patterns,
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
