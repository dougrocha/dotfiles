return {
  'stevearc/oil.nvim',
  opts = {
    float = {
      max_height = 20,
      max_width = 60,
    },
    delete_to_trash = true,
    lsp_file_methods = { autosave_changes = true },
    skip_confirm_for_simple_edits = true,
    default_file_explorer = true,
  },
  keys = {
    {
      '<leader>-',
      '<cmd>Oil --float<cr>',
      desc = 'Open parent diretory (Oil)',
    },
  },
}
