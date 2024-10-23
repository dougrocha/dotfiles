return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "L3MON4D3/LuaSnip", build = "make install_jsregexp" },
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "saadparwaiz1/cmp_luasnip",
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    require("luasnip.loaders.from_vscode").lazy_load()

    -- Set max window height for completion menu
    vim.o.pumheight = 10

    cmp.setup.cmdline("/", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer" },
      },
    })

    cmp.setup({
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip", keyword_length = 2 },
        { name = "buffer", keyword_length = 3 },
        { name = "path" },
      }, {
        {
          name = "lazydev",
          group_index = 0,
        },
      }),
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

        ["<CR>"] = cmp.mapping.confirm({
          select = false,
        }),
      }),
    })
  end,
}
