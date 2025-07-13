return {
    'ibhagwan/fzf-lua',
    dependencies = { 'echasnovski/mini.icons' },
    cmd = 'FzfLua',
    keys = {
        { '<leader>/', '<cmd>FzfLua live_grep<CR>', desc = 'Grep' },
        { '<leader>/', '<cmd>FzfLua grep_visual<CR>', desc = 'Grep', mode = 'x' },
        {
            '<leader>fb',
            function()
                require('fzf-lua').lgrep_curbuf {
                    winopts = {
                        height = 0.6,
                        width = 0.5,
                        preview = { vertical = 'up:70%' },
                    },
                    fzf_opts = {
                        ['--layout'] = 'reverse',
                    },
                }
            end,
            desc = 'Find in current buffer',
        },
        { '<leader>fk', '<cmd>FzfLua keymaps<CR>', desc = 'Find keymaps' },
        { '<leader>fh', '<cmd>FzfLua help_tags<CR>', desc = 'Find help tags' },
        { '<leader>ff', '<cmd>FzfLua files<CR>', desc = 'Find files' },
        { '<leader>fc', '<cmd>FzfLua highlights<CR>', desc = 'Find highlights' },
        { '<leader>fd', '<cmd>FzfLua lsp_document_diagnostics<CR>', desc = 'Find document diagnostics' },
        {
            '<leader>fr',
            function()
                -- Read from ShaDa to include files that were already deleted from the buffer list.
                vim.cmd 'rshada!'
                require('fzf-lua').oldfiles()
            end,
            desc = 'Recently opened files',
        },
        { '<leader>f<', '<cmd>FzfLua resume<cr>', desc = 'Resume last fzf command' },
        { 'z=', '<cmd>FzfLua spell_suggest<CR>', desc = 'Spell suggestions' },
    },
    opts = function()
        local actions = require('fzf-lua').actions

        return {
            'border-fused',
            fzf_opts = {
                ['--info'] = 'default',
                ['--layout'] = 'reverse-list',
            },
            actions = {
                ['alt-i'] = { actions.toggle_ignore },
            },
            keymap = {
                builtin = {
                    ['<C-i>'] = 'toggle-preview',
                },
            },
            winopts = {
                height = 0.70,
                width = 0.70,
                preview = {
                    scrollbar = false,
                    layout = 'vertical',
                    vertical = 'up:40%',
                },
            },
            grep = {
                actions = {
                    ['ctrl-r'] = { actions.toggle_hidden },
                },
            },
            files = {
                winopts = {
                    preview = { hidden = true },
                },
            },
        }
    end,
}
