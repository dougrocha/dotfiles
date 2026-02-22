vim.filetype.add {
    extension = {
        m = 'objc',
        mm = 'objcpp',
    },
}

local util = require 'utils'

---@class ClangdInitializeResult: lsp.InitializeResult
---@field offsetEncoding? string

---@type vim.lsp.Config
return {
    cmd = {
        'clangd',
        '--background-index',
        '--completion-style=detailed',
        '--function-arg-placeholders=false',
    },
    root_markers = { '.clangd', '.clang-format', 'compile_commands.json', '.git' },
    filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
    capabilities = {
        textDocument = {
            completion = {
                editsNearCursor = true,
            },
        },
        offsetEncoding = { 'utf-8', 'utf-16' },
    },
    ---@param init_result ClangdInitializeResult
    on_init = function(client, init_result)
        if init_result.offsetEncoding then
            client.offset_encoding = init_result.offsetEncoding
        end
    end,
    on_attach = function(_, buf)
        vim.keymap.set('n', '<leader>ch', function()
            util.clangd.switch_source_header(buf)
        end, { buffer = buf, desc = 'Switch Source/Header (C/C++)' })
    end,
}
