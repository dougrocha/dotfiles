return {
    'echasnovski/mini.clue',
    version = false,
    opts = function()
        local miniclue = require('mini.clue')
        -- Add a-z/A-Z marks.
        local function mark_clues()
            local marks = {}
            vim.list_extend(marks, vim.fn.getmarklist(vim.api.nvim_get_current_buf()))
            vim.list_extend(marks, vim.fn.getmarklist())

            return vim.iter(marks)
                :map(function(mark)
                    local key = mark.mark:sub(2, 2)

                    -- Just look at letter marks.
                    if not string.match(key, '^%a') then return nil end

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

                    if desc then return { mode = 'n', keys = string.format('`%s', key), desc = desc } end
                end)
                :totable()
        end

        return {
            triggers = {
                -- Leader triggers
                { mode = 'n', keys = '<leader>' },
                { mode = 'x', keys = '<leader>' },

                { mode = 'i', keys = '<C-x>' },
                { mode = 'n', keys = 'g' },
                { mode = 'x', keys = 'g' },
                { mode = 'n', keys = "'" },
                { mode = 'n', keys = '`' },
                { mode = 'x', keys = "'" },
                { mode = 'x', keys = '`' },
                { mode = 'n', keys = '"' },
                { mode = 'x', keys = '"' },
                { mode = 'i', keys = '<C-r>' },
                { mode = 'c', keys = '<C-r>' },
                { mode = 'n', keys = '<C-w>' },
                { mode = 'n', keys = 'z' },
                { mode = 'n', keys = '[' },
                { mode = 'n', keys = ']' },
            },

            clues = {
                { mode = 'n', keys = '<leader>a', desc = '+ai' },
                { mode = 'n', keys = '<leader>b', desc = '+buffers' },
                { mode = 'n', keys = '<leader>c', desc = '+code' },
                { mode = 'x', keys = '<leader>c', desc = '+code' },
                { mode = 'n', keys = '<leader>g', desc = '+git' },
                { mode = 'n', keys = '<leader>l', desc = '+lsp' },
                { mode = 'n', keys = '<leader>o', desc = '+overseer' },
                { mode = 'n', keys = '<leader>r', desc = '+replace' },
                { mode = 'n', keys = '<leader>s', desc = '+search' },
                { mode = 'n', keys = '<leader>t', desc = '+trouble' },
                { mode = 'n', keys = '<leader>x', desc = '+loclist/quickfix' },
                { mode = 'n', keys = '<leader>z', desc = '+notes' },
                { mode = 'n', keys = '[', desc = '+prev' },
                { mode = 'n', keys = ']', desc = '+next' },
                -- Enhance this by adding descriptions for <Leader> mapping groups
                miniclue.gen_clues.builtin_completion(),
                miniclue.gen_clues.g(),
                miniclue.gen_clues.marks(),
                miniclue.gen_clues.registers(),
                miniclue.gen_clues.windows(),
                miniclue.gen_clues.z(),
                mark_clues,
            },
            window = {
                delay = 500,
            },
        }
    end,
}
