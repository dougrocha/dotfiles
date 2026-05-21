vim.api.nvim_create_user_command('PackUpdate', function()
    vim.pack.update()
end, { desc = 'Update all plugins', nargs = 0 })

vim.api.nvim_create_user_command('PackDel', function(opts)
    vim.pack.del({ opts.args })
end, {
    desc = 'Remove a plugin',
    nargs = 1,
    complete = function()
        return vim.iter(vim.pack.get()):map(function(p) return p.spec.name end):totable()
    end,
})

vim.api.nvim_create_user_command('PackList', function()
    local names = vim.iter(vim.pack.get()):map(function(p) return p.spec.name end):totable()
    vim.notify(table.concat(names, '\n'), vim.log.levels.INFO)
end, { desc = 'List installed plugins', nargs = 0 })

vim.api.nvim_create_user_command('ToggleFormat', function()
    vim.g.autoformat = not vim.g.autoformat
    vim.notify(string.format('%s formatting...', vim.g.autoformat and 'Enabling' or 'Disabling'), vim.log.levels.INFO)
end, { desc = 'Toggle conform.nvim auto-formatting', nargs = 0 })

vim.api.nvim_create_user_command('ToggleInlayHints', function()
    vim.g.inlay_hints = not vim.g.inlay_hints
    vim.notify(string.format('%s inlay hints...', vim.g.inlay_hints and 'Enabling' or 'Disabling'), vim.log.levels.INFO)

    local mode = vim.api.nvim_get_mode().mode
    vim.lsp.inlay_hint.enable(vim.g.inlay_hints and (mode == 'n' or mode == 'v'))
end, { desc = 'Toggle inlay hints', nargs = 0 })
