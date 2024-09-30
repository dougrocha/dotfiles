local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    import = "plugins",
  },
  {
    "dougrocha/keytrack.nvim",
    name = "keytrack",
    dir = "C:/Users/dougr/Dev/keytrack-nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    enabled = true,
    opts = {
      keymaps = {
        { key = "<leader>wd", desc = "Delete Window" },
        { key = "<leader>sf", desc = "Search Files with telescope" },
        { key = "<leader>a", desc = "Add harpoon file" },
        { key = "<leader>fw", desc = "Search for word under cursor" },
        { key = "<leader>/", desc = "Grep workspace" },
        { key = "<leader>bn", desc = "Next buffer" },
        { key = "j", desc = "Down" },
      },
      suffix = "Tracked",
    },
  },
}, {
  install = {
    missing = true,
  },
  ui = {
    border = "rounded",
  },
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    enabled = true,
    notify = false,
  },
})

P = function(v)
  print(vim.inspect(v))
  return v
end
