return {
  {
    'wincent/base16-nvim',
    lazy = false,
    priority = 1000,
    enabled = true,
    config = function()
      vim.cmd([[colorscheme base16-gruvbox-dark-hard]])
      vim.o.background = 'dark'
      -- Make comments more prominent -- they are important.
      local bools = vim.api.nvim_get_hl(0, { name = 'Boolean' })
      vim.api.nvim_set_hl(0, 'Comment', bools)
      -- Make it clearly visible which argument we're at.
      local marked = vim.api.nvim_get_hl(0, { name = 'PMenu' })
      vim.api.nvim_set_hl(0, 'LspSignatureActiveParameter', {
        fg = marked.fg,
        bg = marked.bg,
        ctermfg = marked.ctermfg,
        ctermbg = marked.ctermbg,
        bold = true,
      })
    end,
  },
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    enabled = false,
    config = function()
      require('rose-pine').setup({
        variant = 'auto',
        highlight_groups = {
          TelescopeBorder = { fg = 'overlay', bg = 'overlay' },
          TelescopeNormal = { fg = 'subtle', bg = 'overlay' },
          TelescopeSelection = { fg = 'text', bg = 'highlight_med' },
          TelescopeSelectionCaret = { fg = 'love', bg = 'highlight_med' },
          TelescopeMultiSelection = { fg = 'text', bg = 'highlight_high' },

          TelescopeTitle = { fg = 'base', bg = 'love' },
          TelescopePromptTitle = { fg = 'base', bg = 'pine' },
          TelescopePreviewTitle = { fg = 'base', bg = 'iris' },

          TelescopePromptNormal = { fg = 'text', bg = 'surface' },
          TelescopePromptBorder = { fg = 'surface', bg = 'surface' },
        },
      })
      vim.cmd('colorscheme rose-pine')
    end,
  },
  {
    'rebelot/kanagawa.nvim', -- Kanagawa Theme
    lazy = false,
    enabled = false,
    priority = 1000,
    config = function()
      require('kanagawa').setup({
        colors = {
          theme = {
            all = {
              ui = {
                bg_gutter = 'none',
              },
            },
          },
        },
        overrides = function(colors)
          local theme = colors.theme
          return {
            TelescopeTitle = { fg = theme.ui.special, bold = true },
            TelescopePromptNormal = { bg = theme.ui.bg_p1 },
            TelescopePromptBorder = { fg = theme.ui.bg_p1, bg = theme.ui.bg_p1 },
            TelescopeResultsNormal = {
              fg = theme.ui.fg_dim,
              bg = theme.ui.bg_m1,
            },
            TelescopeResultsBorder = {
              fg = theme.ui.bg_m1,
              bg = theme.ui.bg_m1,
            },
            TelescopePreviewNormal = { bg = theme.ui.bg_dim },
            TelescopePreviewBorder = {
              bg = theme.ui.bg_dim,
              fg = theme.ui.bg_dim,
            },
            Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 }, -- add `blend = vim.o.pumblend` to enable transparency
            PmenuSel = { fg = 'NONE', bg = theme.ui.bg_p2 },
            PmenuSbar = { bg = theme.ui.bg_m1 },
            PmenuThumb = { bg = theme.ui.bg_p2 },
          }
        end,
      })
      require('kanagawa').load('wave')
    end,
  },
  {
    'Mofiqul/dracula.nvim', -- Dracula Theme
    enabled = false,
    lazy = false,
    priority = 1000,
    config = function() vim.cmd.colorscheme('dracula') end,
  },
}
