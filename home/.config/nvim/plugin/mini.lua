local add = require('pack').add

-- mini.nvim core utilities
add {
    {
        'nvim-mini/mini.nvim',
        setup = false,
        on_setup = function()
            require('mini.align').setup()
            require('mini.surround').setup()
            require('mini.move').setup()
            require('mini.icons').setup()
            require('mini.splitjoin').setup()
            require('mini.bracketed').setup()

            local hipatterns = require 'mini.hipatterns'
            hipatterns.setup {
                highlighters = {
                    todo = { pattern = 'TODO[^:%s]*', group = 'MiniHipatternsTodo' },
                    hex_color = hipatterns.gen_highlighter.hex_color(),
                },
            }

            vim.keymap.set('n', '<leader>bd', function()
                require('mini.bufremove').delete(0, false)
            end, { desc = 'Delete current buffer' })

            vim.keymap.set('n', '<leader>cj', function()
                require('mini.splitjoin').toggle()
            end, { desc = 'Split/join code block' })
        end,
    },
}

-- mini.clue — which-key style hints
add {
    {
        'nvim-mini/mini.nvim',
        module_name = 'mini.clue',
        opts = function()
            local miniclue = require 'mini.clue'

            -- Add a-z/A-Z marks.
            local function mark_clues()
                local marks = {}
                vim.list_extend(marks, vim.fn.getmarklist(vim.api.nvim_get_current_buf()))
                vim.list_extend(marks, vim.fn.getmarklist())

                return vim.iter(marks)
                    :map(function(mark)
                        local key = mark.mark:sub(2, 2)

                        -- Just look at letter marks.
                        if not string.match(key, '^%a') then
                            return nil
                        end

                        -- For global marks, use the file as a description.
                        -- For local marks, use the line number and content.
                        local desc
                        if mark.file then
                            desc = vim.fn.fnamemodify(mark.file, ':p:~:.')
                        elseif mark.pos[1] and mark.pos[1] ~= 0 then
                            local line_num = mark.pos[2]
                            local lines = vim.fn.getbufline(mark.pos[1], line_num)
                            if lines and lines[1] then
                                desc = string.format('%d: %s', line_num, lines[1]:gsub('^%s*', ''))
                            end
                        end

                        if desc then
                            return { mode = 'n', keys = string.format('`%s', key), desc = desc }
                        end
                    end)
                    :totable()
            end

            return {
                triggers = {
                    -- Leader triggers.
                    { mode = { 'n', 'x' }, keys = '<leader>' },

                    -- Builtins.
                    { mode = { 'n', 'x' }, keys = 'g' },
                    { mode = { 'n', 'x' }, keys = '`' },
                    { mode = { 'n', 'x' }, keys = '"' },
                    { mode = { 'i', 'c' }, keys = '<C-r>' },
                    { mode = 'n', keys = '<C-w>' },
                    { mode = 'i', keys = '<C-x>' },
                    { mode = 'n', keys = 'z' },
                    -- Moving between stuff.
                    { mode = 'n', keys = '[' },
                    { mode = 'n', keys = ']' },
                },

                clues = {
                    { mode = { 'n', 'x' }, keys = '<leader>c', desc = '+code' },
                    { mode = { 'n', 'x' }, keys = '<leader>f', desc = '+find' },
                    { mode = 'n', keys = '<leader>b', desc = '+buffers' },
                    { mode = 'n', keys = '<leader>d', desc = '+debug' },
                    { mode = 'n', keys = '<leader>l', desc = '+lsp' },
                    { mode = 'n', keys = '<leader>w', desc = '+window' },
                    { mode = 'n', keys = '<leader>x', desc = '+loclist/quickfix' },
                    { mode = 'n', keys = '[', desc = '+prev' },
                    { mode = 'n', keys = ']', desc = '+next' },

                    -- Builtins
                    miniclue.gen_clues.g(),
                    miniclue.gen_clues.marks(),
                    miniclue.gen_clues.registers(),
                    miniclue.gen_clues.windows(),
                    miniclue.gen_clues.z(),

                    -- custom
                    mark_clues,
                },
                window = {
                    delay = 500,
                },
            }
        end,
    },
}

-- mini.files — file explorer
local map_split = function(buf_id, lhs, direction)
    local rhs = function()
        local cur_target = MiniFiles.get_explorer_state().target_window
        if cur_target == nil or MiniFiles.get_fs_entry().fs_type == 'directory' then
            return
        end

        local new_target = vim.api.nvim_win_call(cur_target, function()
            vim.cmd(direction .. ' split')
            return vim.api.nvim_get_current_win()
        end)

        MiniFiles.set_target_window(new_target)

        MiniFiles.go_in { close_on_file = true }
    end

    -- Adding `desc` will result into `show_help` entries
    local desc = 'Split ' .. direction
    vim.keymap.set('n', lhs, rhs, { buffer = buf_id, desc = desc })
end

add {
    {
        'nvim-mini/mini.nvim',
        module_name = 'mini.files',
        opts = {
            mappings = {
                show_help = '?',
                go_in_plus = '<cr>',
                go_out_plus = '<tab>',
            },
            content = {
                filter = function(entry)
                    return entry.fs_type ~= 'file' or entry.name ~= '.DS_Store'
                end,
            },
            options = { permanent_delete = false },
        },
        on_setup = function()
            vim.keymap.set('n', '<leader>e', function()
                local bufname = vim.api.nvim_buf_get_name(0)
                local path = vim.fn.fnamemodify(bufname, ':p')

                -- Noop if the buffer isn't valid.
                if path and vim.uv.fs_stat(path) then
                    require('mini.files').open(bufname, false)
                end
            end, { desc = 'Open file diretory' })

            -- Borrowed from mariasolos
            -- Keeps track of when the explorer is opened
            local minifiles_explorer_group = vim.api.nvim_create_augroup('minifiles', { clear = true })
            vim.api.nvim_create_autocmd('User', {
                group = minifiles_explorer_group,
                pattern = 'MiniFilesExplorerOpen',
                callback = function()
                    vim.g.minifiles_active = true
                end,
            })
            vim.api.nvim_create_autocmd('User', {
                group = minifiles_explorer_group,
                pattern = 'MiniFilesExplorerClose',
                callback = function()
                    vim.g.minifiles_active = false
                end,
            })

            -- is built in with commit 4f6f84a
            -- vim.api.nvim_create_autocmd('User', {
            --     pattern = { 'MiniFilesActionRename', 'MiniFilesActionMove' },
            --     callback = function(args)
            --         local will_rename_method = 'workspace/willRenameFiles'
            --         local did_rename_method = 'workspace/didRenameFiles'
            --
            --         local params = {
            --             files = {
            --                 {
            --                     oldUri = vim.uri_from_fname(args.data.from),
            --                     newUri = vim.uri_from_fname(args.data.to),
            --                 },
            --             },
            --         }
            --
            --         local lsp_clients = vim.lsp.get_clients()
            --         for _, client in ipairs(lsp_clients) do
            --             if client:supports_method(will_rename_method) then
            --                 local res = client:request_sync(will_rename_method, params, 1000, 0)
            --                 if res and res.result then
            --                     vim.lsp.util.apply_workspace_edit(res.result, client.offset_encoding)
            --                 end
            --             end
            --         end
            --
            --         for _, client in ipairs(lsp_clients) do
            --             if client:supports_method(did_rename_method) then
            --                 client:notify(did_rename_method, params)
            --             end
            --         end
            --     end,
            -- })

            vim.api.nvim_create_autocmd('User', {
                desc = 'Add MiniFiles split keymaps',
                pattern = 'MiniFilesBufferCreate',
                callback = function(args)
                    local buf_id = args.data.buf_id
                    map_split(buf_id, '<C-s>', 'belowright horizontal')
                    map_split(buf_id, '<C-v>', 'belowright vertical')
                end,
            })
        end,
    },
}

-- mini.ai — better text objects
add {
    { 'nvim-treesitter/nvim-treesitter-textobjects', setup = false },
}

add {
    {
        'nvim-mini/mini.nvim',
        module_name = 'mini.ai',
        event = { 'BufReadPre', 'BufNewFile' },
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
    },
}

-- mini.snippets
add {
    {
        'nvim-mini/mini.nvim',
        module_name = 'mini.snippets',
        event = 'InsertEnter',
        opts = function()
            local gen_loader = require('mini.snippets').gen_loader
            local lang_patterns = {
                tsx = { 'typescript.json' },
            }
            return {
                snippets = {
                    gen_loader.from_lang { lang_patterns = lang_patterns },
                },
            }
        end,
    },
}
