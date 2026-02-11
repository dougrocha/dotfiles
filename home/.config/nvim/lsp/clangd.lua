local util = require 'utils'

---@type vim.lsp.Config
return {
    cmd = {
        'clangd',
        '--background-index',
        '--completion-style=detailed',
        '--function-arg-placeholders=false',
    },
    root_markers = { '.clangd', 'compile_commands.json', '.git' },
    filetypes = { 'c', 'cpp' },
    capabilities = {
        textDocument = {
            completion = {
                editsNearCursor = true,
            },
        },
        offsetEncoding = { 'utf-8', 'utf-16' },
    },
    on_attach = function(_, buf)
        vim.keymap.set('n', '<leader>ch', function()
            util.clangd.switch_source_header(buf)
        end, { buffer = buf, desc = 'Switch Source/Header (C/C++)' })
    end,
}
