return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  ---@class wk.Opts
  opts = {
    preset = 'modern',
    spec = {
      {
        mode = { 'n', 'v' },
        { '<leader>f', group = 'Find' },
        { '<leader>l', group = 'Lsp' },
        { '<leader>g', group = 'Git' },
        { '<leader>r', group = 'Replace' },
        { '<leader>s', group = 'Search' },
        { '<leader>t', group = 'Trouble' },
        { '<leader>w', group = 'Windows' },
        { '<leader>z', group = 'Notes' },
      },
    },
  },
  keys = {
    {
      '<leader>?',
      function() require('which-key').show({ global = false }) end,
      desc = 'Buffer Local Keymaps (which-key)',
    },
  },
}
