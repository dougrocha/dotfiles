return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp", -- source for nvim lsp,
    "hrsh7th/cmp-buffer", -- source for text in buffer,
    "hrsh7th/cmp-path", -- source for file system paths
    "saadparwaiz1/cmp_luasnip", -- for autocompletion
    {
      "L3MON4D3/LuaSnip", -- snippet engine
      lazy = true,
      build = "make install_jsregexp",
      dependencies = {
        "rafamadriz/friendly-snippets",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
    },
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    -- Set max window height for completion menu
    vim.o.pumheight = 10

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
        ["<C-n>"] = cmp.mapping.select_next_item(), -- next suggestion
        ["<C-p>"] = cmp.mapping.select_prev_item(), -- previous suggestion

        -- scroll docs in cmp menu
        ["<C-u>"] = cmp.mapping.scroll_docs(-4),
        ["<C-d>"] = cmp.mapping.scroll_docs(4),

        -- <c-l> will move right in current snippet expansion.
        ["<C-l>"] = cmp.mapping(function()
          if luasnip.expand_or_locally_jumpable() then
            return luasnip.expand_or_jump()
          end
        end, { "i", "s" }),
        -- <c-h> will move left in current snippet expansion.
        ["<C-h>"] = cmp.mapping(function()
          if luasnip.locally_jumpable(-1) then
            return luasnip.jump(-1)
          end
        end, { "i", "s" }),

        ["<C-e>"] = cmp.mapping.abort(), -- close competion window

        -- manually show completion menu
        ["<C-Space>"] = cmp.mapping.complete(),

        ["<CR>"] = cmp.mapping.confirm({
          select = false,
        }),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "copilot", group_index = 2 },
        { name = "luasnip", max_item_count = 3 },
        { name = "path", max_item_count = 3 },
      }, {
        { name = "buffer", max_item_count = 5 },
      }),
    })
  end,
}
