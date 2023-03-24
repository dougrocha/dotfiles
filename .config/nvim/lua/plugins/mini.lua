return {
  "echasnovski/mini.nvim",
  version = "*",
  config = function()
    require("mini.basics").setup({
      options = {
        basic = false,
        extra_ui = true,
      },
      mappings = {
        windows = true,
        move_with_alt = true,
      },
    })
    require("mini.pairs").setup()
    require("mini.starter").setup()
    require("mini.statusline").setup()
    require("mini.comment").setup()
    require("mini.indentscope").setup()
    require("mini.move").setup()
  end,
}
