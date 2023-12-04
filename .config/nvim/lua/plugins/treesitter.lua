return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = "VeryLazy",
  cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
  opts = {
    highlight = {
      enable = true,
    },
    sync_install = false,
    indent = { enabled = true },
    ensure_installed = {
      "javascript",
      "typescript",
      "gitignore",
      "gitattributes",
      "tsx",
      "regex",
      "svelte",
      "markdown",
      "markdown_inline",
      "lua",
      "html",
      "css",
      "json",
      "jsonc",
      "yaml",
      "toml",
      "rust",
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<C-space>",
        node_incremental = "<C-space>",
        scope_incremental = false,
        node_decremental = "<bs>",
      },
    },
  },
  config = function(_, opts)
    if type(opts.ensure_installed) == "table" then
      ---@type table<string, boolean>
      local added = {}
      opts.ensure_installed = vim.tbl_filter(function(lang)
        if added[lang] then
          return false
        end
        added[lang] = true
        return true
      end, opts.ensure_installed)
    end
    require("nvim-treesitter.configs").setup(opts)
  end,
}
