return {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
        "hrsh7th/cmp-buffer",          -- source for text in buffer
        "hrsh7th/cmp-path",            -- source for file system paths
        "onsails/lspkind.nvim",
        "L3MON4D3/LuaSnip",            -- snippet engine
        "saadparwaiz1/cmp_luasnip",    -- source for snippets
        "rafamadriz/friendly-snippets" -- useful snippets
    },
    config = function()
        local cmp = require("cmp")

        local luasnip = require("luasnip")

        local lspkind = require("lspkind")

        -- load snippets from VSCode
        require("luasnip.loaders.from_vscode").lazy_load()

        cmp.setup({
            completion = {
              completeopt = "menu, menuone, preview, noselect",
            },
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-k>"] = cmp.mapping.select_prev_item(),
                ["<C-j>"] = cmp.mapping.select_next_item(),
                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-e>"] = cmp.mapping.abort(),
                ["<CR>"] = cmp.mapping.confirm({
                    behavior = cmp.ConfirmBehavior.Replace,
                    select = true,
                }),
            }),
            sources = {
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = 'buffer' },
                { name = 'path' },
            },
            formatting = {
                format = lspkind.cmp_format({
                    maxwidth = 50,
                    ellipsis_char = "...",
                })
            }
        })
    end,
}
