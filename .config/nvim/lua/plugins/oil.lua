return {
  "stevearc/oil.nvim",
  depeneencies = {
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    float = {
      max_height = 20,
      max_width = 60,
    },
    keymaps = {
      ["g?"] = "actions.show_help",
      ["<CR>"] = "actions.select",
      ["<C-s>"] = "actions.select_vsplit",
      ["<C-h>"] = "actions.select_split",
      ["<C-t>"] = "actions.select_tab",
      ["<C-p>"] = "actions.preview", -- Will not work in floating window
      ["<C-c>"] = "actions.close",
      ["<C-l>"] = "actions.refresh",
      ["-"] = "actions.parent",
      ["_"] = "actions.open_cwd",
      ["`"] = "actions.cd",
      ["~"] = "actions.tcd",
      ["gs"] = "actions.change_sort",
      ["gx"] = "actions.open_external",
      ["g."] = "actions.toggle_hidden",
      ["g\\"] = "actions.toggle_trash",
    },
    delete_to_trash = true, -- Send delete operations to trash instead of deleting permanently
    -- Set to true to autosave buffers that are updated with LSP willRenameFiles
    -- Set to "unmodified" to only save unmodified buffers
    lsp_rename_autosave = false,
  },
  keys = {
    {
      "<leader>-",
      "<cmd>Oil --float<cr>",
      desc = "Open parent diretory (Oil)",
    },
  },
}
