return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    defaults = {
      mode = { "n", "v" },
      ["g"] = { name = "+goto" },
      ["<leader>b"] = { name = "+buffer" },
      ["<leader>d"] = { name = "+debug" },
      ["<leader>f"] = { name = "+file/find" },
      ["<leader>g"] = { name = "+git" },
      ["<leader>s"] = { name = "+search" },
      ["<leader>w"] = { name = "+windows" },
      ["<leader>x"] = { name = "+trouble" },
    },
  },
  config = function(_, opts)
    local wk = require("which-key")

    wk.setup(opts)
    wk.register(opts.defaults)
  end,
}
