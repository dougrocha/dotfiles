return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  opts = {
    ensure_installed = {
      "lua",
      "rust",
    },
    auto_install = true,
    highlight = { enable = true },
    incremental_selection = { enable = false },
    textobjects = { enable = false },
    indent = { enabled = false },
  },
}
