return {
    'echasnovski/mini.nvim',
    version = false,
    event = 'VeryLazy',
    keys = {
        {
            '<leader>bd',
            function() require('mini.bufremove').delete(0, false) end,
            desc = 'Delete current buffer',
        },
    },
    config = function()
        require('mini.ai').setup()

        require('mini.align').setup()
        require('mini.surround').setup()
        require('mini.move').setup()
        require('mini.icons').setup({
            filetype = { astro = { glyph = '' } },
        })
        require('mini.statusline').setup()
        require('mini.splitjoin').setup()
        require('mini.bracketed').setup()

        local hipatterns = require('mini.hipatterns')
        local hi_words = require('mini.extra').gen_highlighter.words
        hipatterns.setup({
            highlighters = {
                todo = hi_words({ 'TODO' }, 'MiniHipatternsTodo'),
                hex_color = hipatterns.gen_highlighter.hex_color(),
            },
        })
    end,
}
