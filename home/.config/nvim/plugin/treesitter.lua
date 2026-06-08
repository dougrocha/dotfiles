local add = require('pack').add

local langs = {
    'bash',
    'cpp',
    'gitcommit',
    'java',
    'json',
    'json5',
    'lua',
    'odin',
    'markdown',
    'markdown_inline',
    'regex',
    'rust',
    'toml',
    'tsx',
    'typescript',
}

add {
    {
        'nvim-treesitter/nvim-treesitter',
        module_name = 'nvim-treesitter',
        setup = false,
        on_update = 'TSUpdate',
        on_setup = function()
            local treesitter = require 'nvim-treesitter'
            treesitter.install(langs)

            local parser_to_filetype = {
                tsx = 'typescriptreact',
            }

            local patterns = {}
            for _, lang in ipairs(langs) do
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
    },
}
