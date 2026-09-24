-- Run a shell command in a terminal split, emacs compile-mode style.
-- The command runs from the project root and is remembered for that project.
-- When it exits, its output is parsed into the quickfix list.

local default_commands = {
    rust = 'cargo run',
}

-- Extra error formats on top of 'errorformat':
-- rust's `--> file:line:col` and odin's `file(line:col) message`.
local efm = table.concat({
    '%\\s%#--> %f:%l:%c',
    '%f(%l:%c) %m',
    vim.o.errorformat,
}, ',')

-- Commands are remembered per project, keyed by git root.
local store = require 'utils.store'

---@type integer?
local compile_buf
---@type string?
local last_root

---@return string
local function project_root()
    -- From the compile window, stay in the project that was last compiled.
    if last_root and vim.api.nvim_get_current_buf() == compile_buf then
        return last_root
    end
    return vim.fs.root(0, '.git') or vim.fn.getcwd()
end

-- Error paths are relative to the project root, but quickfix resolves them against
-- the current directory, so parse output from the root.
---@param root string
---@param fn fun(): any
local function from_root(root, fn)
    local prev = vim.fn.chdir(root)
    local ok, result = pcall(fn)
    if prev ~= '' then
        vim.fn.chdir(prev)
    end
    assert(ok, result)
    return result
end

---@param buf integer
---@param root string
local function jump_to_error(buf, root)
    local line = vim.api.nvim_get_current_line()
    local item = from_root(root, function()
        return vim.fn.getqflist({ lines = { line }, efm = efm }).items[1]
    end)
    if not item or item.valid ~= 1 or item.bufnr == 0 then
        return
    end

    vim.cmd.wincmd 'p'
    if vim.api.nvim_get_current_buf() == buf then
        vim.cmd 'aboveleft split'
    end
    vim.api.nvim_win_set_buf(0, item.bufnr)
    vim.api.nvim_win_set_cursor(0, { item.lnum, math.max(item.col - 1, 0) })
end

---@param root string
---@param cmd string
local function run(root, cmd)
    last_root = root
    store.update('compile', function(data)
        data[root] = cmd
    end)

    -- Reuse the compile window if it's still open.
    local win = compile_buf and vim.fn.bufwinid(compile_buf) or -1
    if win == -1 then
        vim.cmd 'belowright split'
        win = vim.api.nvim_get_current_win()
    else
        vim.api.nvim_set_current_win(win)
    end

    local old_buf = compile_buf
    local buf = vim.api.nvim_create_buf(false, true)
    compile_buf = buf
    vim.api.nvim_win_set_buf(win, buf)
    if old_buf and vim.api.nvim_buf_is_valid(old_buf) then
        vim.api.nvim_buf_delete(old_buf, { force = true })
    end

    vim.fn.jobstart(cmd, {
        term = true,
        cwd = root,
        on_exit = function(_, code)
            if not vim.api.nvim_buf_is_valid(buf) then
                return
            end

            local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            from_root(root, function()
                vim.fn.setqflist({}, ' ', { title = cmd, lines = lines, efm = efm })
            end)
            vim.notify(
                string.format('%s: exited with %d', cmd, code),
                code == 0 and vim.log.levels.INFO or vim.log.levels.WARN
            )
        end,
    })

    vim.keymap.set('n', '<CR>', function()
        jump_to_error(buf, root)
    end, { buffer = buf, desc = 'Jump to error' })
    vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = buf, desc = 'Close compile window' })

    -- Keep editing in the window we came from.
    vim.cmd.wincmd 'p'
end

vim.api.nvim_create_user_command('Compile', function(opts)
    local root = project_root()
    if opts.args ~= '' then
        run(root, opts.args)
        return
    end

    vim.ui.input({
        prompt = 'Compile: ',
        default = store.read('compile')[root] or default_commands[vim.bo.filetype],
        completion = 'shellcmd',
    }, function(cmd)
        if cmd and cmd ~= '' then
            run(root, cmd)
        end
    end)
end, { desc = 'Run a compile command', nargs = '*', complete = 'shellcmd' })

vim.api.nvim_create_user_command('Recompile', function()
    local root = project_root()
    local cmd = store.read('compile')[root]
    if cmd then
        run(root, cmd)
    else
        vim.cmd.Compile()
    end
end, { desc = "Re-run this project's compile command", nargs = 0 })

vim.keymap.set('n', '<leader>R', '<cmd>Compile<CR>', { desc = 'Compile' })
vim.keymap.set('n', '<leader>r', '<cmd>Recompile<CR>', { desc = 'Re-compile' })
