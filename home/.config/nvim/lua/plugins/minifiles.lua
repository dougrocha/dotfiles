local map_split = function(buf_id, lhs, direction)
    local rhs = function()
        local cur_target = MiniFiles.get_explorer_state().target_window
        if cur_target == nil or MiniFiles.get_fs_entry().fs_type == 'directory' then return end

        local new_target = vim.api.nvim_win_call(cur_target, function()
            vim.cmd(direction .. ' split')
            return vim.api.nvim_get_current_win()
        end)

        MiniFiles.set_target_window(new_target)

        MiniFiles.go_in({ close_on_file = true })
    end

    -- Adding `desc` will result into `show_help` entries
    local desc = 'Split ' .. direction
    vim.keymap.set('n', lhs, rhs, { buffer = buf_id, desc = desc })
end

return {
    'echasnovski/mini.files',
    event = 'VeryLazy',
    keys = {
        {
            '<leader>e',
            function()
                local bufname = vim.api.nvim_buf_get_name(0)
                local path = vim.fn.fnamemodify(bufname, ':p')

                -- Noop if the buffer isn't valid.
                if path and vim.uv.fs_stat(path) then require('mini.files').open(bufname, false) end
            end,
            desc = 'Open file diretory',
        },
    },
    opts = {
        mappings = {
            close = '<C-c>',
            go_in_plus = '<cr>',
            go_out_plus = '<tab>',
        },
        options = { permanent_delete = false },
    },
    config = function(_, opts)
        require('mini.files').setup(opts)

        -- Borrowed from mariasolos
        -- Keeps track of when the explorer is opened
        local minifiles_explorer_group = vim.api.nvim_create_augroup('minifiles', { clear = true })
        vim.api.nvim_create_autocmd('User', {
            group = minifiles_explorer_group,
            pattern = 'MiniFilesExplorerOpen',
            callback = function() vim.g.minifiles_active = true end,
        })
        vim.api.nvim_create_autocmd('User', {
            group = minifiles_explorer_group,
            pattern = 'MiniFilesExplorerClose',
            callback = function() vim.g.minifiles_active = false end,
        })

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
}
