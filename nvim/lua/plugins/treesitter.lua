return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  opts = {
    auto_install = true,
    sync_install = false,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    indent = { enabled = true },
    ensure_installed = {
      "lua",
      "rust",
    },
  },
}
