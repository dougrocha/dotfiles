return {
  { -- snippet engine
    "L3MON4D3/LuaSnip",
    event = "VeryLazy",
    build = "make install_jsregexp",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      -- load all vscode snippets
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- source for nvim lsp
      "hrsh7th/cmp-buffer", -- source for text in buffer
      "hrsh7th/cmp-path", -- source for file system paths
      "rafamadriz/friendly-snippets", -- useful snippets
      "saadparwaiz1/cmp_luasnip", -- for autocompletion
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        completion = {
          completeopt = "menu,menuone,preview,noselect",
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
          ["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
          ["<C-e>"] = cmp.mapping.abort(), -- close competion window
          ["<CR>"] = cmp.mapping.confirm({ -- confirm completion
            select = true,
          }),
        }),
        sources = cmp.config.sources({
          { name = "copilot", group_index = 1 },
          { name = "nvim_lsp", group_index = 2 },
          { name = "luasnip", group_index = 2 },
          { name = "path", group_index = 2 },
        }, {
          { name = "buffer" },
        }),
        window = {
          max_height = 15,
        },
      })
    end,
  },
}
