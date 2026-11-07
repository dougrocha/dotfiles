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
        setup = false,
        on_update = function()
            vim.cmd 'TSUpdate'
        end,
        on_setup = function()
            local treesitter = require 'nvim-treesitter'

            local installed = treesitter.get_installed()
            local missing = vim.tbl_filter(function(lang)
                return not vim.list_contains(installed, lang)
            end, langs)
            if #missing > 0 then
                treesitter.install(missing)
            end

            local group = vim.api.nvim_create_augroup('dougrocha/treesitter', { clear = true })
            vim.api.nvim_create_autocmd('FileType', {
                group = group,
                callback = function(args)
                    if not pcall(vim.treesitter.start, args.buf) then
                        return
                    end

                    if not no_ts_indent[vim.bo[args.buf].filetype] then
                        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end

                    vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
                    vim.wo[0][0].foldmethod = 'expr'
                end,
            })
        end,
    },
}
