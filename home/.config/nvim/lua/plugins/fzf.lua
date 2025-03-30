return {
  'ibhagwan/fzf-lua',
  dependencies = { 'echasnovski/mini.icons' },
  cmd = 'FzfLua',
  keys = {
    { '<leader>/', '<cmd>FzfLua live_grep<CR>', desc = 'Grep workspace' },
    { '<leader>fw', '<cmd>FzfLua grep_cword<CR>', desc = 'Find word under cursor' },
    { '<leader>fu', '<cmd>FzfLua changes<CR>', desc = 'Find undo Tree' },
    { '<leader>,', '<cmd>FzfLua buffers<CR>', desc = 'Find existing buffers' },
    { '<C-f>', '<cmd>FzfLua grep_curbuf<CR>', desc = 'Find in current buffer' },
    { '<leader>sk', '<cmd>FzfLua keymaps<CR>', desc = 'Search Keymaps' },
    { '<leader>sh', '<cmd>FzfLua help_tags<cr>', desc = 'Search help tags' },
    { '<leader>sf', '<cmd>FzfLua files<CR>', desc = 'Find files' },
    { '<leader>sD', '<cmd>FzfLua diagnostics_workspace<CR>', desc = 'Search Workspace Diagnostics' },
    { '<leader>ss', '<cmd>FzfLua spell_suggest<CR>', desc = 'Spell suggestions' },
    { '<leader>s.', '<cmd>FzfLua oldfiles<CR>', desc = 'Search recently opened files' },
    { '<C-p>', '<cmd>FzfLua git_files<CR>', desc = 'Search git files' },

    { '<leader>gbr', '<cmd>FzfLua git_branches<CR>', desc = 'Git Branches' },
  },
  opts = function()
    local fzf = require('fzf-lua')
    local actions = fzf.actions

    return {
      files = {
        cwd_prompt = false,
        actions = {
          ['alt-i'] = { actions.toggle_ignore },
        },
      },
      grep = {
        actions = {
          ['alt-i'] = { actions.toggle_ignore },
          ['ctrl-r'] = { actions.toggle_hidden },
        },
      },
      git = {
        branches = {
          winopts = { preview = { layout = 'vertical' } },
        },
      },
    }
  end,
}
