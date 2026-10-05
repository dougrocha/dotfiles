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

-- Slang's indents query inherits from hlsl, which has none, so cindent works better.
local no_ts_indent = { shaderslang = true }

add {
    {
        'nvim-treesitter/nvim-treesitter',
        module_name = 'nvim-treesitter',
        setup = false,
        on_update = function() vim.cmd 'TSUpdate' end,
        on_setup = function()
            local treesitter = require 'nvim-treesitter'
            treesitter.install(langs)

            local group = vim.api.nvim_create_augroup('dougrocha/treesitter', { clear = true })
            vim.api.nvim_create_autocmd('FileType', {
                group = group,
                callback = function(args)
                    -- Enable highlighting for any filetype with an installed parser
                    if not pcall(vim.treesitter.start, args.buf) then
                        return
                    end

                    -- Enable indentation for the buffer, except where the indent query is broken
                    if not no_ts_indent[vim.bo[args.buf].filetype] then
                        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end

                    -- Enable fold
                    vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
                    vim.wo[0][0].foldmethod = 'expr'
                end,
            })
        end,
    },
}
