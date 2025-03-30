return {
  'stevearc/oil.nvim',
  cmd = { 'Oil' },
  opts = {
    delete_to_trash = true,
    skip_confirm_for_simple_edits = true,
    lsp_file_methods = { autosave_changes = true },
    float = {
      max_height = 20,
      max_width = 60,
    },
  },
  keys = {
    {
      '<leader>-',
      '<cmd>Oil --float<cr>',
      desc = 'Open parent diretory (Oil)',
    },
  },
}
