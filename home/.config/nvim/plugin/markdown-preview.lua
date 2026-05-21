local add = require('pack').add

add {
    {
        'iamcco/markdown-preview.nvim',
        pattern = 'markdown',
        setup = false,
        on_update = function()
            vim.fn['mkdp#util#install']()
        end,
        on_setup = function()
            vim.keymap.set('n', '<leader>cp', '<cmd>MarkdownPreviewToggle<cr>', { desc = 'Markdown Preview' })
        end,
    },
}
