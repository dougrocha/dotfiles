---@type vim.lsp.Config
return {
    cmd = { 'vscode-eslint-language-server', '--stdio' },
    filetypes = {
        'javascript',
        'javascriptreact',
        'typescript',
        'typescriptreact',
        'vue',
        'json',
    },
    root_markers = { '.eslintrc', '.eslintrc.js', '.eslintrc.cjs', '.eslintrc.yaml', '.eslintrc.yml', 'package.json' },
    workspace_required = true,
    settings = {
        validate = 'on',
        packageManager = vim.NIL,
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
        workingDirectory = { mode = 'location' },
        codeAction = {
            disableRuleComment = { enable = true, location = 'separateLine' },
            showDocumentation = { enable = true },
        },
    },
    before_init = function(_, config)
        local root_dir = config.root_dir
        if root_dir then
            config.settings = config.settings or {}
            config.settings.workspaceFolder = {
                uri = 'file://' .. root_dir,
                name = 'workspace',
            }
        end
    end,
    handlers = {
        ['eslint/openDoc'] = function(_, params)
            vim.ui.open(params.url)
            return {}
        end,
        ['eslint/probeFailed'] = function()
            vim.notify('LSP[eslint]: Probe failed.', vim.log.levels.WARN)
            return {}
        end,
        ['eslint/noLibrary'] = function()
            vim.notify('LSP[eslint]: Unable to load ESLint library.', vim.log.levels.WARN)
            return {}
        end,
    },
}
