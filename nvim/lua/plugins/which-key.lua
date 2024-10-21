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
      height = { min = 3, max = 25 },
    },
    layout = {
      width = { min = 5, max = 50 }, -- min and max width of the columns
      spacing = 10, -- spacing between columns
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
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    wk.add(opts.defaults)
  end,
}
