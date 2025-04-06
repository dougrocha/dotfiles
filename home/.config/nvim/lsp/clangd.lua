local util = require('utils')

---@type vim.lsp.Config
return {
  cmd = {
    'clangd',
    '--background-index',
    '--clang-tidy',
    '--header-insertion=iwyu',
    '--completion-style=detailed',
    '--function-arg-placeholders=false',
    '--fallback-style=llvm',
    '--enable-config',
    '--pretty',
  },
  root_markers = { 'compile_commands.json', '.clangd' },
  filetypes = { 'c', 'cpp' },
  capabilities = {
    textDocument = {
      completion = {
        editsNearCursor = true,
      },
    },
    offsetEncoding = { 'utf-8', 'utf-16' },
  },
  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
    clangdFileStatus = true,
  },
  on_attach = function(_, buf)
    vim.keymap.set(
      'n',
      '<leader>ch',
      function() util.clangd.switch_source_header(buf) end,
      { buffer = buf, desc = 'Switch Source/Header (C/C++)' }
    )
  end,
}
