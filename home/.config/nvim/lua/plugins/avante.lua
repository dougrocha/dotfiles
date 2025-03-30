return {
  'yetone/avante.nvim',
  event = 'VeryLazy',
  version = false,
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'stevearc/dressing.nvim',
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    'zbirenbaum/copilot.lua',
    {
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { 'markdown', 'Avante' },
      },
      ft = { 'markdown', 'Avante' },
    },
  },
  opts = {
    provider = 'copilot',
    -- copilot = {
    --   endpoint = 'https://api.githubcopilot.com/',
    --   -- model = 'o1',
    --   model = "claude-3.7-sonnet",
    -- },
    hints = { enabled = false },
    behavior = {
      auto_set_keymaps = false,
    },
  },
}
