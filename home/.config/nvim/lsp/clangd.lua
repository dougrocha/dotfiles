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
  },
  root_markers = { '.clangd' },
  filetypes = { 'c', 'cpp' },
  on_attach = function(_, buf)
    vim.keymap.set(
      'n',
      '<leader>ch',
      function() util.clangd.switch_source_header(buf) end,
      { buffer = buf, desc = 'Switch Source/Header (C/C++)' }
    )
  end,
}
