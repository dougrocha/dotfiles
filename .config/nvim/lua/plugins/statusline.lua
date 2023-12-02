return {
  "echasnovski/mini.statusline",
  version = "*",
  event = "VeryLazy",
  config = function()
    require("mini.statusline").setup()
  end,
}
