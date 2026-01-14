return {
    'nvim-mini/mini.ai',
    version = false,
    event = 'BufReadPre',
    dependencies = {
        'nvim-treesitter/nvim-treesitter-textobjects',
        'nvim-mini/mini.extra',
    },
    opts = function()
        local gen_spec = require('mini.ai').gen_spec
        local gen_ai_spec = require('mini.extra').gen_ai_spec

        return {
            n_lines = 500,
            silent = true,
            custom_textobjects = {
                f = gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }, {}), -- function
                g = gen_ai_spec.buffer(), -- buffer
                t = { '<([%p%w]-)%f[^<%w][^<>]->.-</%1>', '^<.->().*()</[^/]->$' }, -- tags
            },
        }
    end,
}
