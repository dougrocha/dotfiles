return {
  'catppuccin/nvim',
  lazy = false,
  priority = 1000,
  name = 'catppuccin',
  ---@type CatppuccinOptions
  opts = {
    integrations = {
      treesitter = true,
      blink_cmp = true,
      dropbar = true,
      fzf = true,
      fidget = true,
      harpoon = true,
      native_lsp = {
        enabled = true,
        underlines = {
          errors = { 'undercurl' },
          hints = { 'undercurl' },
          warnings = { 'undercurl' },
          information = { 'undercurl' },
        },
      },
      snacks = {
        enabled = true,
      },
      which_key = true,
    },
  },
  config = function(_, opts)
    require('catppuccin').setup(opts)

    vim.cmd.colorscheme('catppuccin')
  end,
}
