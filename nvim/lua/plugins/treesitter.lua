return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPost", "BufNewFile" },
  build = ":TSUpdate",
  opts = {
    auto_install = true,
    sync_install = false,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    autotag = { enable = true },
    indent = { enabled = true },
    ensure_installed = {
      "typescript",
      "tsx",
      "lua",
      "rust",
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<C-g>",
        node_incremental = "<C-g>",
        node_decremental = "<C-h>",
      },
    },
  },
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)

    -- MDX
    vim.filetype.add({
      extension = {
        mdx = "mdx",
      },
    })
    vim.treesitter.language.register("markdown", "mdx")
  end,
}
