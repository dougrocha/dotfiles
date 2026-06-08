---@type vim.lsp.Config
return {
    cmd = { 'ols' },
    filetypes = { 'odin' },
    root_markers = { 'ols.json', '.git', '*.odin' },
    init_options = {
        checker_args = '-strict-style',
    },
}
