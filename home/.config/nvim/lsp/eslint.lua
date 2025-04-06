---@type vim.lsp.Config
return {
  cmd = { 'vscode-eslint-language-server', '--stdio' },
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'graphql' },
  root_markers = { '.eslintrc', '.eslintrc.js', '.eslintrc.json', 'eslint.config.js', 'eslint.config.mjs' },
  settings = {
    validate = 'on',
    packageManager = 'pnpm',
    useESLintClass = false,
    experimental = { useFlatConfig = false },
    codeActionOnSave = { enable = false, mode = 'all' },
    format = false,
    quiet = false,
    onIgnoredFiles = 'off',
    options = {},
    rulesCustomizations = {},
    run = 'onType',
    problems = { shortenToSingleLine = false },
    nodePath = '',
    codeAction = {
      disableRuleComment = { enable = true, location = 'separateLine' },
      showDocumentation = { enable = true },
    },
  },
  handlers = {
    ['eslint/openDoc'] = function(_, params)
      vim.ui.open(params.url)
      return {}
    end,
    ['eslint/probeFailed'] = function() vim.notify('LSP[eslint]: Probe failed.', vim.log.levels.WARN) end,
    ['eslint/noLibrary'] = function() vim.notify('LSP[eslint]: Unable to load ESLint library.', vim.log.levels.WARN) end,
  },
}
