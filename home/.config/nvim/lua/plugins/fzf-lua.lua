return {
    'ibhagwan/fzf-lua',
    dependencies = { 'echasnovski/mini.icons' },
    cmd = 'FzfLua',
    keys = {
        { '<leader>/', '<cmd>FzfLua live_grep<CR>', desc = 'Grep' },
        { '<leader>/', '<cmd>FzfLua live_grep<CR>', desc = 'Grep', mode = 'x' },
        {
            '<leader>sb',
            function()
                require('fzf-lua').lgrep_curbuf({
                    winopts = {
                        height = 0.6,
                        width = 0.5,
                        preview = {
                            vertical = 'up:70%',
                        },
                    },
                })
            end,
            desc = 'Find in current buffer',
        },
        { '<leader>sk', '<cmd>FzfLua keymaps<CR>', desc = 'Search keymaps' },
        { '<leader>sh', '<cmd>FzfLua help_tags<cr>', desc = 'Search help tags' },
        { '<leader>sf', '<cmd>FzfLua files<CR>', desc = 'Find files' },
        { '<leader>sd', '<cmd>FzfLua lsp_document_diagnostics<CR>', desc = 'Search document diagnostics' },
        { '<leader>sD', '<cmd>FzfLua lsp_workspace_diagnostics<CR>', desc = 'Search workspace diagnostics' },
        { '<leader>s.', '<cmd>FzfLua oldfiles<CR>', desc = 'Search recently opened files' },
        { '<C-p>', '<cmd>FzfLua git_files<CR>', desc = 'Search git files' },
        { '<leader>gbr', '<cmd>FzfLua git_branches<CR>', desc = 'Git branches' },
        { 'z=', '<cmd>FzfLua spell_suggest<CR>', desc = 'Spell suggestions' },
    },
    opts = function()
        local actions = require('fzf-lua').actions

        return {
            fzf_opts = {
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
