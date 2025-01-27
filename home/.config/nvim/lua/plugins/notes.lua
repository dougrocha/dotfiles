local home = vim.fn.expand('~/second-brain')

return {
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    ft = { 'markdown' },
    build = 'cd app && npm install && git restore .',
    init = function() vim.g.mkdp_filetypes = { 'markdown' } end,
    keys = {
      {
        '<leader>cp',
        ft = 'markdown',
        '<cmd>MarkdownPreviewToggle<cr>',
        desc = 'Markdown Preview',
      },
    },
  },
  {
    'renerocksai/telekasten.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    cmd = { 'Telekasten' },
    ft = { 'markdown' },
    keys = {
      { '<leader>zb', '<cmd>Telekasten show_backlinks<CR>', desc = 'Show backlinks' },
      { '<leader>zd', '<cmd>Telekasten goto_today<CR>', desc = 'Go to today' },
      { '<leader>zf', function() require('telekasten').find_notes({ with_live_grep = true }) end, desc = 'Find notes' },
      { '<leader>zg', '<cmd>Telekasten search_notes<CR>', desc = 'Search notes' },
      { '<leader>zi', '<cmd>Telekasten insert_img_link<CR>', desc = 'Insert image link' },
      { '<leader>zn', '<cmd>Telekasten new_note<CR>', desc = 'New note' },
      { '<leader>zz', '<cmd>Telekasten follow_link<CR>', desc = 'Follow link' },
    },
    opts = {
      home = home,
      dailies = home .. '/daily',
      templates = home .. '/templates',
      template_new_daily = home .. '/templates/daily.md',
      template_new_weekly = home .. '/templates/weekly.md',
      enable_create_new = false,
      auto_set_filetype = false,
    },
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
    ft = { 'markdown' },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      code = {
        sign = false,
        position = 'right',
        width = 'block',
        right_pad = 10,
      },
      latex = {
        enabled = false,
      },
    },
  },
}
