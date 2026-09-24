-- Borrowed From MariaOsSol Borrowed from https://github.com/lewis6991/dotfiles/blob/0071d6f1a97f8f6080eb592c4838d92f77901e84/config/nvim/lua/gizmos/marksigns.lua

local ns = vim.api.nvim_create_namespace 'dougrocha/marks'

---@param bufnr integer
---@param mark vim.fn.getmarklist.ret.item
local function decor_mark(bufnr, mark)
    pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, mark.pos[2] - 1, 0, {
        sign_text = mark.mark:sub(2),
        sign_hl_group = 'DiagnosticSignOk',
    })
end

vim.api.nvim_set_decoration_provider(ns, {
    on_win = function(_, _, bufnr, top_row, bot_row)
        -- Only enable mark signs for buffers with a filename.
        if vim.api.nvim_buf_get_name(bufnr) == '' then
            return
        end

        vim.api.nvim_buf_clear_namespace(bufnr, ns, top_row, bot_row)

        local current_file = vim.api.nvim_buf_get_name(bufnr)

        -- Global marks
        for _, mark in ipairs(vim.fn.getmarklist()) do
            if mark.mark:match '^.[a-zA-Z]$' then
                local mark_file = vim.fn.fnamemodify(mark.file, ':p:a')
                if current_file == mark_file then
                    decor_mark(bufnr, mark)
                end
            end
        end

        -- Local marks
        for _, mark in ipairs(vim.fn.getmarklist(bufnr)) do
            if mark.mark:match '^.[a-zA-Z]$' then
                decor_mark(bufnr, mark)
            end
        end
    end,
})

-- Redraw screen when marks are changed via `m` commands
vim.on_key(function(_, typed)
    if typed:sub(1, 1) ~= 'm' then
        return
    end

    local mark = typed:sub(2)

    vim.schedule(function()
        if mark:match '[A-Z]' then
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                vim.api.nvim__redraw { win = win, range = { 0, -1 } }
            end
        else
            vim.api.nvim__redraw { range = { 0, -1 } }
        end
    end)
end, ns)

-- Menu of file marks (A-Z): which letter points at which file.
local function toggle_menu()
    local marks = vim.iter(vim.fn.getmarklist())
        :filter(function(mark)
            return mark.mark:match "^'%u$"
        end)
        :totable()

    local lines = vim.tbl_map(function(mark)
        return string.format('%s  %s:%d', mark.mark:sub(2), vim.fn.fnamemodify(mark.file, ':~:.'), mark.pos[2])
    end, marks)
    if #lines == 0 then
        lines = { 'No file marks, set one with mA-mZ' }
    end

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    vim.bo[buf].bufhidden = 'wipe'

    local width = math.min(math.max(40, unpack(vim.tbl_map(vim.fn.strdisplaywidth, lines))) + 2, vim.o.columns - 4)
    local height = #lines
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        row = math.floor((vim.o.lines - height) / 2),
        col = math.floor((vim.o.columns - width) / 2),
        border = 'rounded',
        title = ' Marks ',
        title_pos = 'center',
    })

    local function close()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end

    ---@return string?
    local function letter()
        return vim.api.nvim_get_current_line():match '^(%u)  '
    end

    vim.keymap.set('n', '<CR>', function()
        local mark = letter()
        close()
        if mark then
            vim.cmd.normal { '`' .. mark, bang = true }
        end
    end, { buffer = buf, desc = 'Jump to mark' })

    vim.keymap.set('n', 'd', function()
        local mark = letter()
        if not mark then
            return
        end
        vim.cmd.delmarks(mark)
        close()
        toggle_menu()
    end, { buffer = buf, desc = 'Delete mark' })

    for _, key in ipairs { 'q', '<Esc>', '<C-e>' } do
        vim.keymap.set('n', key, close, { buffer = buf, desc = 'Close marks menu' })
    end

    vim.api.nvim_create_autocmd('WinLeave', {
        buffer = buf,
        once = true,
        callback = function()
            vim.schedule(close)
        end,
    })
end

vim.keymap.set('n', '<C-e>', toggle_menu, { desc = 'Marks menu' })
