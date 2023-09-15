return {
  {
    "echasnovski/mini.starter",
    event = "VimEnter",
    opts = {},
  },
  {
    "echasnovski/mini.basics",
    event = "VeryLazy",
    opts = {
      options = {
        basic = false,
        extra_ui = true,
      },
      mappings = {
        windows = true,
        move_with_alt = true,
      },
    },
  },
  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    opts = {},
  },
  {
    "echasnovski/mini.comment",
    version = false,
    opts = {},
  },
  {
    "echasnovski/mini.indentscope",
    event = { "BufRead", "BufNewFile" },
    opts = {},
  },
  {

    "echasnovski/mini.move",
    event = "VeryLazy",
    opts = {},
  },
  {
    "echasnovski/mini.tabline",
    event = "VimEnter",
    opts = {},
  },
}
