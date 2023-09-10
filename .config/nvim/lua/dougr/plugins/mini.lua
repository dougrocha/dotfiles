return {
  {
    "echasnovski/mini.starter",
    event = "VimEnter",
    opts = true,
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
    opts = true,
  },
  {
    "echasnovski/mini.comment",
    event = { "BufRead", "BufNewFile" },
    opts = true,
  },
  {
    "echasnovski/mini.indentscope",
    event = { "BufRead", "BufNewFile" },
    opts = true,
  },
  {
    "echasnovski/mini.move",
    event = "VeryLazy",
    opts = true,
  },
  {
    "echasnovski/mini.tabline",
    event = "VimEnter",
    opts = true,
  },
}
