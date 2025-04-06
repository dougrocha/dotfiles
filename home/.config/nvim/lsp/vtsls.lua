local settings = {
  suggest = { completeFunctionCalls = true },
  inlayHints = {
    functionLikeReturnTypes = { enabled = true },
    parameterNames = { enabled = 'literals' },
    variableTypes = { enabled = true },
  },
  updateImportsOnFileMove = { enabled = 'always' },
}

---@type vim.lsp.Config
return {
  cmd = { 'vtsls', '--stdio' },
  filetypes = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
  },
  root_markers = { 'tsconfig.json', 'package.json' },
  settings = {
    vtsls = {
      autoUseWorkspaceTsdk = true,
      experimental = {
        completion = {
          enableServerSideFuzzyMatch = true,
        },
      },
    },
    javascript = settings,
    typescript = settings,
  },
  on_attach = function(_, bufnr)
    local opts = { buffer = bufnr }
    vim.keymap.set(
      'n',
      '<leader>co',
      function()
        vim.lsp.buf.code_action({
          apply = true,
          context = {
            only = { 'source.organizeImpor' },
            diagnostics = {},
          },
        })
      end,
      vim.tbl_extend('force', opts, { desc = 'Organize Imports' })
    )
  end,
}
