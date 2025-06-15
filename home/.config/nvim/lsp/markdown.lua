---@type vim.lsp.Config
return {
    cmd = { '/Users/douglasrocha/dev/rust_markdown_lsp/target/debug/rust_markdown_lsp' },
    -- cmd = { 'rust_markdown_lsp' },
    -- cmd = { 'marksman', 'server' },
    filetypes = { 'markdown', 'markdown.mdx' },
    -- root_markers = { '.marksman.toml' },
    root_dir = vim.fs.root(0, '.git'),
    single_file_support = true,
}
