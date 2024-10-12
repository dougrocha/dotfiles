return {
  "stevearc/oil.nvim",
  dependencies = { { "echasnovski/mini.icons", opts = {} } },
  opts = {
    float = {
      max_height = 20,
      max_width = 60,
    },
    delete_to_trash = true, -- Send delete operations to trash instead of deleting permanently

    -- Set to true to autosave buffers that are updated with LSP willRenameFiles
    -- Set to "unmodified" to only save unmodified buffers
    lsp_file_methods = { autosave_changes = true },

    -- Skip the confirmation popup for simple operations (:help oil.skip_confirm_for_simple_edits)
    skip_confirm_for_simple_edits = true,
    default_file_explorer = true,
  },
  keys = {
    {
      "<leader>-",
      "<cmd>Oil --float<cr>",
      desc = "Open parent diretory (Oil)",
    },
  },
}
