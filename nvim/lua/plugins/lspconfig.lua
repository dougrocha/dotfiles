vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(event)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[event.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

    -- Buffer Local Keybindings
    -- after language server attaches
    local options = { noremap = true, silent = true, buffer = event.buf }

    local nmap = function(keys, func, opts)
      if opts then
        if opts.desc then
          opts.desc = "LSP: " .. opts.desc
        end
        options = vim.tbl_extend("force", options, opts)
      end
      vim.keymap.set("n", keys, func, options)
    end

    nmap("<leader>k", vim.lsp.buf.hover, { desc = "Show Documentation for Symbol" })
    nmap("gr", "<cmd>Telescope lsp_references<CR>", { desc = "Go to References" })
    nmap("gD", vim.lsp.buf.declaration, { desc = "Go to Declaration" })
    nmap("gi", "<cmd>Telescope lsp_implementations<CR>", { desc = "Go to Implementation" })
    nmap("gd", "<cmd>Telescope lsp_definitions<CR>", { desc = "Go to Definition" })
    nmap("gt", "<cmd>Telescope lsp_type_definitions<CR>", { desc = "Go to Type Definition" })
    nmap("<leader>rn", vim.lsp.buf.rename, { desc = "Rename Symbol" })

    nmap("<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", { desc = "Show Buffer Diagnostics" })
    nmap("<leader>d", vim.diagnostic.open_float, { desc = "Show Line Diagnostics" })
    nmap("[d", vim.diagnostic.goto_prev, { desc = "Go to Previous Diagnostic" })
    nmap("]d", vim.diagnostic.goto_next, { desc = "Go to Next Diagnostic" })

    vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Actions" })
  end,
})

local servers = {
  "clangd",
  "jsonls",
  "marksman",
  "gopls",
  "lua_ls",
  "svelte",
  "tailwindcss",
}

return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "folke/neoconf.nvim", config = true, ft = "lua" },
    { "folke/neodev.nvim", config = true, ft = "lua" },

    "williamboman/mason.nvim",
    "hrsh7th/cmp-nvim-lsp",
    { "j-hui/fidget.nvim", opts = {} },
  },
  config = function()
    require("neodev").setup({})

    local lsp_config = require("lspconfig")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for name, icon in pairs(signs) do
      name = "DiagnosticSign" .. name
      vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
    end

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

    for _, server in pairs(servers) do
      local opts = {
        capabilities = capabilities,
      }

      local require_ok, settings = pcall(require, "plugins.settings." .. server)
      if require_ok then
        opts = vim.tbl_deep_extend("force", settings, opts)
      end

      lsp_config[server].setup(opts)
    end
  end,
}
