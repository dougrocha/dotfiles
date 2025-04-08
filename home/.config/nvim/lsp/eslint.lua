---@type vim.lsp.Config
return {
  cmd = { 'vscode-eslint-language-server', '--stdio' },
  settings = {
    validate = 'on',
    packageManager = 'pnpm',
    useESLintClass = false,
    experimental = {
      useFlatConfig = false,
    },
    codeActionOnSave = {
      enable = false,
      mode = 'all',
    },
    format = false,
    quiet = false,
    onIgnoredFiles = 'off',
    options = {},
    rulesCustomizations = {},
    run = 'onType',
    problems = { shortenToSingleLine = false },
    nodePath = '',
    workingDirectory = { mode = 'location' },
    codeAction = {
      disableRuleComment = { enable = true, location = 'separateLine' },
      showDocumentation = { enable = true },
    },
  },
  filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
    'vue',
    'svelte',
    'astro',
  },
  root_markers = {
    '.eslintrc',
    '.eslintrc.js',
    '.eslintrc.cjs',
    '.eslintrc.yaml',
    '.eslintrc.yml',
    '.eslintrc.json',
    'eslint.config.js',
  },
  before_init = function(params, config)
    config.settings.workspaceFolder = {
      uri = params.rootPath,
      name = vim.fn.fnamemodify(params.rootPath, ':t'),
    }
  end,
  ---@type table<string, lsp.Handler>
  handlers = {
    ['eslint/openDoc'] = function(_, params)
      vim.ui.open(params.url)
      return {}
    end,
    ['eslint/probeFailed'] = function() vim.notify('LSP[eslint]: Probe failed.', vim.log.levels.WARN) end,
    ['eslint/noLibrary'] = function() vim.notify('LSP[eslint]: Unable to load ESLint library.', vim.log.levels.WARN) end,
  },
}
