---@type vim.lsp.Config
return {
    cmd = { 'slangd' },
    filetypes = { 'hlsl', 'shaderslang' },
    root_markers = { 'slangdconfig.json', '.clang-format', '.git' },
}
