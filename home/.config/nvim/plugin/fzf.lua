local add = require('pack').add

add {
    {
        'ibhagwan/fzf-lua',
        module_name = 'fzf-lua',
        opts = function()
            local icons = require 'icons'
            local actions = require('fzf-lua').actions

            return {
                { 'border-fused', 'hide' },
                fzf_colors = {
                    ['bg'] = { 'bg', 'Normal' },
                    ['gutter'] = { 'bg', 'Normal' },
                    ['info'] = { 'fg', 'Conditional' },
                    ['scrollbar'] = { 'bg', 'Normal' },
                    ['separator'] = { 'fg', 'Comment' },
                },
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
                lsp = {
                    code_actions = {
                        winopts = {
                            width = 70,
                            height = 20,
                            relative = 'cursor',
                            preview = {
                                hidden = true,
                                vertical = 'down:50%',
                            },
                        },
                    },
                },
                previewers = {
                    codeaction = { toggle_behavior = 'extend' },
                },
                grep = {
                    hidden = true,
                    header_prefix = icons.misc.search .. ' ',
                    rg_opts = '--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -g "!.git" -e',
                    rg_glob_fn = function(query, opts)
                        local regex, flags = query:match(string.format('^(.*)%s(.*)$', opts.glob_separator))
                        -- Return the original query if there's no separator.
                        return (regex or query), flags
                    end,
                },
                files = {
                    winopts = {
                        preview = { hidden = true },
                    },
                },
            }
        end,
        on_setup = function()
            local fzf = require 'fzf-lua'

            vim.keymap.set('n', '<leader>/', '<cmd>FzfLua live_grep<CR>', { desc = 'Grep' })
            vim.keymap.set('x', '<leader>/', '<cmd>FzfLua grep_visual<CR>', { desc = 'Grep' })
            vim.keymap.set('n', '<leader>fb', function()
                fzf.lgrep_curbuf {
                    winopts = {
                        height = 0.6,
                        width = 0.5,
                        preview = { vertical = 'up:70%' },
                    },
                    fzf_opts = {
                        ['--layout'] = 'reverse',
                    },
                }
            end, { desc = 'Find in current buffer' })
            vim.keymap.set('n', '<leader>fk', '<cmd>FzfLua keymaps<CR>', { desc = 'Find keymaps' })
            vim.keymap.set('n', '<leader>fh', '<cmd>FzfLua help_tags<CR>', { desc = 'Find help tags' })
            vim.keymap.set('n', '<leader>ff', '<cmd>FzfLua files<CR>', { desc = 'Find files' })
            vim.keymap.set('n', '<leader>fc', '<cmd>FzfLua highlights<CR>', { desc = 'Find highlights' })
            vim.keymap.set(
                'n',
                '<leader>fd',
                '<cmd>FzfLua lsp_document_diagnostics<CR>',
                { desc = 'Find document diagnostics' }
            )
            vim.keymap.set('n', '<leader>fr', '<cmd>FzfLua oldfiles<CR>', { desc = 'Recently opened files' })
            vim.keymap.set('n', '<leader>f<', '<cmd>FzfLua resume<cr>', { desc = 'Resume last fzf command' })
            vim.keymap.set('n', 'z=', '<cmd>FzfLua spell_suggest<CR>', { desc = 'Spell suggestions' })
        end,
    },
}
