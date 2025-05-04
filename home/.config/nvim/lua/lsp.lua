local diagnostic_icons = require('icons').diagnostic_icons

local methods = vim.lsp.protocol.Methods

vim.g.inlay_hints = false

local function on_attach(client, bufnr)
    ---@param lhs string
    ---@param rhs string|function
    ---@param desc string
    ---@param mode? string|string[]
    ---@param opts? table
    local function keymap(lhs, rhs, desc, mode, opts)
        if type(mode) == 'nil' then mode = 'n' end
        opts = opts or {}
        vim.keymap.set(mode, lhs, rhs, vim.tbl_extend('force', { buffer = bufnr, desc = desc }, opts))
    end

    keymap('grr', '<cmd>FzfLua lsp_references<CR>', 'vim.lsp.buf.references()')
    keymap('gra', '<cmd>FzfLua lsp_code_actions<CR>', 'vim.lsp.buf.code_action()', { 'n', 'x' })
    keymap('gy', '<cmd>FzfLua lsp_typedefs<CR>', 'Go to type definition')

    keymap('K', function() vim.lsp.buf.hover({ border = 'rounded' }) end, 'Hover Information')

    keymap('[d', function() vim.diagnostic.jump({ count = -1, float = true }) end, 'Previous diagnostic')
    keymap(']d', function() vim.diagnostic.jump({ count = 1, float = true }) end, 'Next diagnostic')
    keymap(
        '[e',
        function() vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR, float = true }) end,
        'Previous error'
    )
    keymap(
        ']e',
        function() vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR, float = true }) end,
        'Next error'
    )

    local format_cmd = function() require('conform').format({ lsp_fallback = true }) end
    keymap('<leader>lf', format_cmd, 'Format')
    vim.keymap.set('v', '<leader>lf', format_cmd, { desc = 'Format selection' })

    if client:supports_method(methods.textDocument_definition) then
        keymap('gd', function() require('fzf-lua').lsp_definitions({ jump1 = true }) end, 'Go to definition')
        keymap('gD', function() require('fzf-lua').lsp_definitions({ jump1 = false }) end, 'Peek definition')
    end

    if client:supports_method(methods.textDocument_documentColor) then vim.lsp.document_color.enable(true, bufnr) end
end

-- Update mappings when registering dynamic capabilities.
local register_capability = vim.lsp.handlers[methods.client_registerCapability]
vim.lsp.handlers[methods.client_registerCapability] = function(err, res, ctx)
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    if not client then return end

    on_attach(client, vim.api.nvim_get_current_buf())

    return register_capability(err, res, ctx)
end

vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'Setup LSP keymaps',
    callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if not client then return end

        local bufnr = event.buf
        on_attach(client, bufnr)
    end,
})

for severity, icon in pairs(diagnostic_icons) do
    local hl = 'DiagnosticSign' .. severity:sub(1, 1) .. severity:sub(2):lower()
    vim.fn.sign_define(hl, { text = icon, texthl = hl })
end

vim.diagnostic.config({
    virtual_text = {
        prefix = '',
        spacing = 2,
        format = function(diagnostic)
            -- Use shorter, nicer names for some sources:
            local special_sources = {
                ['Lua Diagnostics.'] = 'lua',
                ['Lua Syntax Check.'] = 'lua',
            }

            local message = diagnostic_icons[vim.diagnostic.severity[diagnostic.severity]]
            if diagnostic.source then
                message = string.format('%s %s', message, special_sources[diagnostic.source] or diagnostic.source)
            end
            if diagnostic.code then message = string.format('%s[%s]', message, diagnostic.code) end

            return message .. ' '
        end,
    },
    float = {
        source = 'if_many',
        prefix = function(diag)
            local level = vim.diagnostic.severity[diag.severity]
            local prefix = string.format(' %s ', diagnostic_icons[level])
            return prefix, 'Diagnostic' .. level:gsub('^%l', string.upper)
        end,
    },
    signs = false,
})

vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
    once = true,
    callback = function()
        local server_configs = vim.iter(vim.api.nvim_get_runtime_file('lsp/*.lua', true))
            :map(function(file) return vim.fn.fnamemodify(file, ':t:r') end)
            :totable()
        vim.lsp.enable(server_configs)
    end,
})
