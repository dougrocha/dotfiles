return {
  "Mofiqul/dracula.nvim", -- Dracula Theme
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd.colorscheme("dracula")
  end,
}
