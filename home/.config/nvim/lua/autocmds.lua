local git = require 'git'

local function augroup(name)
    return vim.api.nvim_create_augroup(name, { clear = true })
end

-- Highlight when yanking a line
vim.api.nvim_create_autocmd('TextYankPost', {
    group = augroup 'highlight_yank',
    callback = function()
        vim.hl.on_yank { higroup = 'Visual' }
    end,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ 'VimResized' }, {
    group = augroup 'resize_splits',
    callback = function()
        local current_tab = vim.fn.tabpagenr()
        vim.cmd 'tabdo wincmd ='
        vim.cmd('tabnext ' .. current_tab)
    end,
})

-- From @mariasolos, will toggle relative numbers depending on window focus
local line_numbers_group = vim.api.nvim_create_augroup('dougrocha/toggle_line_numbers', {})
vim.api.nvim_create_autocmd({ 'BufEnter', 'FocusGained', 'InsertLeave', 'CmdlineLeave', 'WinEnter' }, {
    group = line_numbers_group,
    desc = 'Toggle relative line numbers on',
    callback = function()
        if vim.wo.nu and not vim.startswith(vim.api.nvim_get_mode().mode, 'i') then
            vim.wo.relativenumber = true
        end
    end,
})
vim.api.nvim_create_autocmd({ 'BufLeave', 'FocusLost', 'InsertEnter', 'CmdlineEnter', 'WinLeave' }, {
    group = line_numbers_group,
    desc = 'Toggle relative line numbers off',
    callback = function(args)
        if vim.wo.nu then
            vim.wo.relativenumber = false
        end

        -- Redraw here to avoid having to first write something for the line numbers to update.
        if args.event == 'CmdlineEnter' then
            if not vim.tbl_contains({ '@', '-' }, vim.v.event.cmdtype) then
                vim.cmd.redraw()
            end
        end
    end,
})

-- https://github.com/echasnovski/nvim/blob/a732d0a79dfb2145cb934310016cc580a18a0c8f/src/settings.lua#L26
vim.api.nvim_create_autocmd('FileType', {
    group = augroup 'custom_settings',
    callback = function()
        -- Don't auto-wrap comments and don't insert comment leader after hitting 'o'
        -- If don't do this on `FileType`, this keeps reappearing due to being set in
        -- filetype plugins.
        vim.cmd 'setlocal formatoptions-=c formatoptions-=o'
    end,
    desc = [[Ensure proper 'formatoptions']],
})
