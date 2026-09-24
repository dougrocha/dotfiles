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

-- The terminal is only a display. Output and job lifetime belong to the run.
local current_run

---@return string
local function project_root()
    -- From the compile window, stay in the project that was last compiled.
    if current_run and vim.api.nvim_get_current_buf() == current_run.buf then
        return current_run.root
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

local function publish_diagnostics(run)
    local lines = vim.tbl_map(function(line)
        -- Strip terminal styling and OSC links before errorformat parsing.
        return line:gsub('\27%][^\7\27]*\7', '')
            :gsub('\27%][^\7\27]*\27\\', '')
            :gsub('\27%[[0-?]*[ -/]*[@-~]', '')
            :gsub('\r', '')
    end, run.lines)
    local items = from_root(run.root, function()
        return vim.fn.getqflist({ lines = lines, efm = efm }).items
    end)
    local opts = { title = run.cmd, items = items }
    if run.qf_id and vim.fn.getqflist({ id = run.qf_id }).id == run.qf_id then
        opts.id = run.qf_id
        vim.fn.setqflist({}, 'r', opts)
    else
        vim.fn.setqflist({}, ' ', opts)
        run.qf_id = vim.fn.getqflist({ id = 0 }).id
    end
end

local function show_diagnostics(run)
    publish_diagnostics(run)
    -- Another command may have made a different quickfix list current.
    local target = vim.fn.getqflist({ id = run.qf_id, nr = 0 }).nr
    local current = vim.fn.getqflist({ nr = 0 }).nr
    if target < current then
        vim.cmd('colder ' .. (current - target))
    elseif target > current then
        vim.cmd('cnewer ' .. (target - current))
    end
    vim.cmd.copen()
end

---@return table?
local function parse_location(root, line)
    local item = from_root(root, function()
        return vim.fn.getqflist({ lines = { line }, efm = efm }).items[1]
    end)
    if item and item.valid == 1 and item.bufnr ~= 0 then
        return item
    end
end

-- The terminal hard-wraps long lines, so an error may start a few lines above the cursor.
local function location_under_cursor(run)
    local lnum = vim.api.nvim_win_get_cursor(0)[1]
    for start = lnum, math.max(lnum - 3, 1), -1 do
        local line = table.concat(vim.api.nvim_buf_get_lines(0, start - 1, lnum, false))
        local item = parse_location(run.root, line)
        if item then
            return item
        end
    end
end

local function goto_location(run)
    local item = location_under_cursor(run)
    if not item then
        vim.notify('No error location on this line', vim.log.levels.WARN)
        return
    end

    -- Keep the quickfix position in sync so :cnext continues from here.
    publish_diagnostics(run)
    for i, qf in ipairs(vim.fn.getqflist({ id = run.qf_id, items = 0 }).items) do
        if qf.bufnr == item.bufnr and qf.lnum == item.lnum and qf.col == item.col then
            vim.fn.setqflist({}, 'a', { id = run.qf_id, idx = i })
            break
        end
    end

    if vim.api.nvim_win_is_valid(run.origin) and run.origin ~= vim.api.nvim_get_current_win() then
        vim.api.nvim_set_current_win(run.origin)
    else
        vim.cmd 'aboveleft split'
    end
    vim.api.nvim_win_set_buf(0, item.bufnr)
    local last = vim.api.nvim_buf_line_count(item.bufnr)
    vim.api.nvim_win_set_cursor(0, { math.min(math.max(item.lnum, 1), last), math.max(item.col - 1, 0) })
    vim.cmd 'normal! zz'
end

local function cancel(run)
    if not run or run.finished or run.cancelled then
        return
    end
    run.cancelled = true
    if run.job then
        vim.fn.jobstop(run.job)
    end
end

---@param root string
---@param cmd string
local function run(root, cmd)
    store.update('compile', function(data)
        data[root] = cmd
    end)

    -- Reuse the compile window if it's still open.
    local previous = current_run
    local origin = vim.api.nvim_get_current_win()
    local win = previous and vim.fn.bufwinid(previous.buf) or -1
    if win == -1 then
        vim.cmd 'belowright split'
        win = vim.api.nvim_get_current_win()
    else
        vim.api.nvim_set_current_win(win)
    end

    cancel(previous)
    local buf = vim.api.nvim_create_buf(false, true)
    local run = { root = root, cmd = cmd, buf = buf, origin = origin, lines = { '' } }
    current_run = run
    vim.api.nvim_win_set_buf(win, buf)
    if previous and vim.api.nvim_buf_is_valid(previous.buf) then
        vim.api.nvim_buf_delete(previous.buf, { force = true })
    end

    vim.api.nvim_create_autocmd('BufWipeout', {
        buffer = buf,
        once = true,
        callback = function()
            cancel(run)
        end,
    })

    local ok, job = pcall(vim.fn.jobstart, cmd, {
        term = true,
        cwd = root,
        on_stdout = function(_, data)
            if run.cancelled then
                return
            end
            -- Callback boundaries need not coincide with line boundaries.
            run.lines[#run.lines] = run.lines[#run.lines] .. data[1]
            for i = 2, #data do
                run.lines[#run.lines + 1] = data[i]
            end
        end,
        on_exit = function(_, code)
            run.finished = true
            if run.cancelled or current_run ~= run then
                return
            end

            publish_diagnostics(run)
            vim.notify(
                string.format('%s: exited with %d', cmd, code),
                code == 0 and vim.log.levels.INFO or vim.log.levels.WARN
            )
        end,
    })
    if ok and job > 0 then
        run.job = job
    else
        run.finished = true
        local reason = ok and ('jobstart returned ' .. job) or tostring(job)
        vim.notify(cmd .. ': failed to start: ' .. reason, vim.log.levels.ERROR)
    end

    vim.keymap.set('n', '<CR>', function()
        show_diagnostics(run)
    end, { buffer = buf, desc = 'Show compile diagnostics' })
    vim.keymap.set('n', 'gd', function()
        goto_location(run)
    end, { buffer = buf, desc = 'Go to error location' })
    vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = buf, desc = 'Close compile window' })

    -- Keep editing in the window we came from.
    if vim.api.nvim_win_is_valid(origin) then
        vim.api.nvim_set_current_win(origin)
    end
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
