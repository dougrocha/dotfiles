-- Move between nvim windows and tmux panes with the same keys.
-- The tmux side comes from the vim-tmux-navigator TPM plugin.

local tmux_dirs = { h = 'L', j = 'D', k = 'U', l = 'R' }
local names = { h = 'left', j = 'down', k = 'up', l = 'right' }

-- Set when the last move left nvim for a tmux pane, so <C-\> goes back there.
local tmux_was_last = false

---@param args string[]
local function tmux(args)
    vim.system(vim.list_extend({ 'tmux', 'select-pane', '-t', vim.env.TMUX_PANE }, args))
end

---@param dir 'h'|'j'|'k'|'l'
local function navigate(dir)
    local win = vim.api.nvim_get_current_win()
    vim.cmd.wincmd(dir)

    -- At the edge of the nvim layout, hand off to tmux.
    if vim.env.TMUX and vim.api.nvim_get_current_win() == win then
        tmux { '-' .. tmux_dirs[dir] }
        tmux_was_last = true
    end
end

local function previous()
    if vim.env.TMUX and tmux_was_last then
        tmux { '-l' }
    else
        vim.cmd.wincmd 'p'
    end
end

vim.api.nvim_create_autocmd('WinEnter', {
    group = vim.api.nvim_create_augroup('dougrocha/tmux', { clear = true }),
    callback = function()
        tmux_was_last = false
    end,
})

for dir in pairs(tmux_dirs) do
    vim.keymap.set('n', '<C-' .. dir .. '>', function()
        navigate(dir)
    end, { desc = 'Navigate ' .. names[dir] })
end
vim.keymap.set('n', '<C-\\>', previous, { desc = 'Navigate to previous' })
