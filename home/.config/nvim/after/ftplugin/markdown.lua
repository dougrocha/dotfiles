vim.opt.colorcolumn = ''
vim.opt.spell = true

local client = vim.lsp.start({
  name = 'test_markdown_lsp',
  -- cmd = { '/Users/douglasrocha/dev/go_markdown_lsp/main' },
  cmd = { '/Users/douglasrocha/dev/rust_markdown_lsp/target/release/rust_markdown_lsp' },
  capabilities = require('blink.cmp').get_lsp_capabilities(),
  root_dir = vim.fs.root(0, '.git'),
  on_attach = function(_, buf)
    vim.bo[buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover Information' })
  end,
})

if not client then
  vim.notify('hey, you didnt do good client thing')
else
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'markdown',
    callback = function() vim.lsp.buf_attach_client(0, client) end,
  })
end
