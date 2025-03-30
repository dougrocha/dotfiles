return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    ---@module 'snacks'
    ---@type snacks.Config
    opts = {},
    keys = {
      { '<leader>gg', function() require('snacks').lazygit() end, desc = 'LazyGit' },
      { '<leader>gl', function() require('snacks').lazygit.log() end, desc = 'LazyGit Log (cwd)' },
      { '<leader>gL', function() require('snacks').git.blame_line() end, desc = 'Git Blame Line' },
    },
  },
  {
    'folke/todo-comments.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {},
    keys = {
      { '<leader>st', function() require('todo-comments.fzf').todo() end, desc = 'Todo' },
    },
  },
}
