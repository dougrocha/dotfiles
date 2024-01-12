return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    defaults = {
      mode = { "n", "v" },
      ["<leader>b"] = { name = "+buffer" },
      ["<leader>d"] = { name = "+debug" },
      ["<leader>f"] = { name = "+file/find" },
      ["<leader>g"] = { name = "+git" },
      ["<leader>w"] = { name = "+windows" },
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    wk.register(opts.defaults)
  end,
}
