local M = {}

---@return string
function M.render()
    local buffer_name = vim.fn.expand '%:t'

    return table.concat { ' ', string.format('%%#Winbar#%s', buffer_name) }
end

vim.api.nvim_create_autocmd('BufWinEnter', {
    group = vim.api.nvim_create_augroup('dougrocha/winbar', { clear = true }),
    desc = 'Attach winbar',
    callback = function(args)
        if
            not vim.api.nvim_win_get_config(0).zindex
            and vim.bo[args.buf].buftype == ''
            and vim.api.nvim_buf_get_name(args.buf) ~= ''
            and not vim.wo[0].diff
        then
            vim.wo.winbar = "%{%v:lua.require'winbar'.render()%}"
        end
    end,
})

return M
