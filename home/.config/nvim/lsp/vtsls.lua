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
    filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    root_dir = function(bufnr, cb)
        local fname = vim.uri_to_fname(vim.uri_from_bufnr(bufnr))

        local ts_root = vim.fs.find('tsconfig.json', { upward = true, path = fname })[1]
        -- Use the git root to deal with monorepos where TypeScript is installed in the root node_modules folder.
        local git_root = vim.fs.find('.git', { upward = true, path = fname })[1]

        if git_root then
            cb(vim.fn.fnamemodify(git_root, ':h'))
        elseif ts_root then
            cb(vim.fn.fnamemodify(ts_root, ':h'))
        end
    end,
    settings = {
        vtsls = {
            autoUseWorkspaceTsdk = true,
            experimental = {
                completion = {
                    enableServerSideFuzzyMatch = true,
                    enableProjectDiagnostics = true,
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
                        only = { 'source.organizeImports' },
                        diagnostics = {},
                    },
                })
            end,
            vim.tbl_extend('force', opts, { desc = 'Organize Imports' })
        )
    end,
}
