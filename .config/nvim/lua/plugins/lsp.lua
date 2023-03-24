return {
    -- LSP Configuration & Plugins
    "neovim/nvim-lspconfig",
    dependencies = {
        -- Automatically install LSPs to stdpath for neovim
        {
            "williamboman/mason.nvim",
            opts = {}
        },
        {
            "williamboman/mason-lspconfig.nvim",
            opts = {
                ensure_installed = vim.tbl_keys(servers)
            },
            config = function()
                -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
                local capabilities = vim.lsp.protocol.make_client_capabilities()
                capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

                require("mason-lspconfig").setup_handlers({
                    function(server_name)
                        require("lspconfig")[server_name].setup({
                            capabilities = capabilities,
                            on_attach = on_attach,
                            settings = servers[server_name],
                        })
                    end,
                })
            end
        },

        -- Useful status updates for LSP
        -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
        { "j-hui/fidget.nvim", opts = {} },

        -- Additional lua configuration, makes nvim stuff amazing!
        {
            "folke/neodev.nvim",
            opts = {}
        },
    },
    -- Formatter and linter
    {
        "jose-elias-alvarez/null-ls.nvim",
        requires = { "nvim-lua/plenary.nvim" },
    },
    {
        "jay-babu/mason-null-ls.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "williamboman/mason.nvim",
            "jose-elias-alvarez/null-ls.nvim",
        },
        config = function()
            local null_ls = require("null-ls")

            local formatting = null_ls.builtins.formatting

            null_ls.setup({
                on_attach = on_attach,
                sources = {
                    formatting.eslint_d,
                    formatting.prettierd,
                    formatting.prismaFmt,
                    formatting.stylua,
                    formatting.rustFmt,
                    formatting.rustywind,
                },
            })
        end
    },
}
