return {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    opts = {
        langs = {
            'bash',
            'css',
            'cpp',
            'gitcommit',
            'java',
            'json',
            'json5',
            'kotlin',
            'lua',
            'markdown',
            'markdown_inline',
            'regex',
            'rust',
            'toml',
            'tsx',
            'javascript',
            'typescript',
            'qmljs',
        },
    },
    config = function(_, opts)
        local treesitter = require 'nvim-treesitter'
        treesitter.install(opts.langs)

        local pattern = {}
        for _, lang in ipairs(opts.langs) do
            for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
                table.insert(pattern, ft)
            end
        end

        local group = vim.api.nvim_create_augroup('dougrocha/treesitter', { clear = true })
        vim.api.nvim_create_autocmd('FileType', {
            group = group,
            pattern = pattern,
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
