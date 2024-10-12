return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    plugins = {
      presets = {
        windows = false,
      },
    },
    win = {
      border = "single", -- none, single, double, shadow
      position = "bottom", -- bottom, top
      margin = { 0, 10, 3, 10 }, -- extra window margin [top, right, bottom, left]
      padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
    },
    layout = {
      height = { min = 3, max = 25 }, -- min and max height of the columns
      width = { min = 5, max = 50 }, -- min and max width of the columns
      spacing = 10, -- spacing between columns
      align = "center", -- align columns left, center or right
    },
    defaults = {
      {
      mode = { "n", "v" },
      { "<leader>b", group = "buffer" },
      { "<leader>f", group = "find" },
      { "<leader>l", group = "lsp" },
      { "<leader>r", group = "replace" },
      { "<leader>s", group = "search" },
      { "<leader>t", group = "trouble" },
      { "<leader>w", group = "windows" },
      },
      }
    
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    wk.add(opts.defaults)
  end,
}
