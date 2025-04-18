return {
    'echasnovski/mini.ai',
    event = 'VeryLazy',
    dependencies = 'echasnovski/mini.extra',
    opts = function()
        local gen_ai_spec = require('mini.extra').gen_ai_spec

        return {
            n_lines = 500,
            silent = true,
            custom_textobjects = {
                g = gen_ai_spec.buffer(),
                t = { '<([%p%w]-)%f[^<%w][^<>]->.-</%1>', '^<.->().*()</[^/]->$' }, -- tags
            },
        }
    end,
}
