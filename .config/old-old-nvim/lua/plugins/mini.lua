-- Mini plugins
return {

  {
    "echasnovski/mini.starter",
    event = "VimEnter",
    config = function(_, opts) require("mini.starter").setup(opts) end,
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
    config = function(_, opts) require("mini.basics").setup(opts) end,
  },

  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    config = function(_, opts) require("mini.pairs").setup(opts) end,
  },

  {
    "echasnovski/mini.statusline",
    event = "VeryLazy",
    config = function(_, opts) require("mini.statusline").setup(opts) end,
  },
  {
    "echasnovski/mini.comment",
    event = { "BufRead", "BufNewFile" },
    config = function(_, opts) require("mini.comment").setup(opts) end,
  },
  {
    "echasnovski/mini.indentscope",
    event = { "BufRead", "BufNewFile" },
    config = function(_, opts) require("mini.indentscope").setup(opts) end,
  },
  {
    "echasnovski/mini.move",
    event = "VeryLazy",
    config = function(_, opts) require("mini.move").setup(opts) end,
  },
}