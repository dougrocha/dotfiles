local minifiles_toggle = function(...)
  if not MiniFiles.close() then MiniFiles.open(...) end
end

return {
  'echasnovski/mini.nvim',
  event = 'VeryLazy',
  version = false,
  keys = {
    {
      '<leader>fo',
      minifiles_toggle,
      desc = 'Open file diretory',
    },
  },
  config = function()
    local gen_spec = require('mini.ai').gen_spec
    local gen_ai_spec = require('mini.extra').gen_ai_spec

    require('mini.ai').setup({
      n_lines = 500,
      custom_textobjects = {
        d = gen_ai_spec.number(),
        g = gen_ai_spec.buffer(),
        e = { -- Word with case
          { '%u[%l%d]+%f[^%l%d]', '%f[%S][%l%d]+%f[^%l%d]', '%f[%P][%l%d]+%f[^%l%d]', '^[%l%d]+%f[^%l%d]' },
          '^().*()$',
        },
        t = { '<([%p%w]-)%f[^<%w][^<>]->.-</%1>', '^<.->().*()</[^/]->$' }, -- tags
        u = gen_spec.function_call(), -- u for "Usage"
        U = gen_spec.function_call({ name_pattern = '[%w_]' }), -- without dot in function name
      },
    })

    require('mini.align').setup()
    require('mini.surround').setup()
    require('mini.move').setup()
    require('mini.files').setup({
      mappings = {
        close = '<C-c>',
        go_in_plus = '<CR>',
      },
    })
    require('mini.icons').setup({
      filetype = { astro = { glyph = '' } },
    })
    require('mini.statusline').setup()
    require('mini.splitjoin').setup()
    require('mini.bracketed').setup()
  end,
}
