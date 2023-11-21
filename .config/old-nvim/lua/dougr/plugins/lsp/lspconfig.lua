return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
  },
  config = function()
    local lspconfig = require("lspconfig")

    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    local keymap = vim.keymap

    local nmap = function(keys, func, opts)
      if opts.desc then opts.desc = "LSP: " .. opts.desc end

      keymap.set("n", keys, func, opts)
    end

    local opts = { noremap = true, silent = true }

    local on_attach = function(client, bufnr)
      opts.buffer = bufnr

      opts.desc = "[G]oto [R]eferences"
      nmap("gR", "<cmd>Telescope lsp_references<CR>", opts)

      opts.desc = "[G]oto [D]efinition"
      nmap("gD", vim.lsp.buf.declaration, opts)

      opts.desc = "Show LSP definitions"
      nmap("gd", "<cmd>Telescope lsp_definitions<CR>", opts)

      opts.desc = "[G]oto [I]mplementation"
      nmap("gi", "<cmd>Telescope lsp_implementations<CR>", opts)

      opts.desc = "[G]oto [T]ype definition"
      nmap("gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

      opts.desc = "LSP: See available [C]ode [A]ctions"
      keymap.set("v", "ca", vim.lsp.buf.code_action, opts)

      opts.desc = "Smart rename"
      nmap("<leader>rn", vim.lsp.buf.rename, opts)

      opts.desc = "Show buffer diagnostics"
      nmap("<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

      opts.desc = "Show line diagnostics"
      nmap("<leader>d", vim.diagnostic.open_float, opts)

      opts.desc = "Go to previous diagnostic"
      nmap("[d", vim.diagnostic.goto_prev, opts)

      opts.desc = "Go to next diagnostic"
      nmap("]d", vim.diagnostic.goto_next, opts)

      opts.desc = "Show documentation for what is under cursor"
      nmap("K", vim.lsp.buf.hover, opts)

      opts.desc = "Restart LSP"
      nmap("<leader>rs", ":LspRestart<CR>", opts)
    end

    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- Change the Diagnostic symbols in the sign column (gutter)
    -- (not in youtube nvim video)
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    -- configure html server
    lspconfig["html"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- configure typescript server with plugin
    lspconfig["tsserver"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
      root_dir = lspconfig.util.root_pattern(".git"),
    })

    -- configure tailwindcss server
    lspconfig["tailwindcss"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- configure lua server (with special settings)
    lspconfig["lua_ls"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = { -- custom settings for lua
        Lua = {
          -- make the language server recognize "vim" global
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            -- make language server aware of runtime files
            library = {
              [vim.fn.expand("$VIMRUNTIME/lua")] = true,
              [vim.fn.stdpath("config") .. "/lua"] = true,
            },
          },
        },
      },
    })

    lspconfig["rust_analyzer"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })
  end,
}
