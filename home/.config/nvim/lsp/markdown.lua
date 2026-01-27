---@type vim.lsp.Config
return {
    cmd = { '/Users/douglasrocha/dev/rust_markdown_lsp/target/debug/rust_markdown_lsp' },
    -- cmd = { 'rust_markdown_lsp' },
    -- cmd = { 'marksman', 'server' },
    filetypes = { 'markdown', 'markdown.mdx' },
    root_markers = { '.git', '.obsidian', 'rust_markdown_lsp.toml' },
}
