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

    nmap("K", vim.lsp.buf.hover, { desc = "Show Documentation for Symbol" })
    nmap("gr", vim.lsp.buf.references, { desc = "Go to References" })
    nmap("gD", vim.lsp.buf.declaration, { desc = "Go to Declaration" })
    nmap("gi", vim.lsp.buf.implementation, { desc = "Go to Implementation" })
    nmap("gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
    nmap("gt", vim.lsp.buf.type_definition, { desc = "Go to Type Definition" })
    nmap("<leader>r", vim.lsp.buf.rename, { desc = "Rename Symbol" })

    nmap(
      "<leader>D",
      "<cmd>Telescope diagnostics bufnr=0<CR>",
      { desc = "Show Buffer Diagnostics" }
    )
    nmap(
      "<leader>d",
      vim.diagnostic.open_float,
      { desc = "Show Line Diagnostics" }
    )
    nmap("[d", function()
      vim.diagnostic.jump({ count = -1, float = true })
    end, { desc = "Go to Previous Diagnostic" })
    nmap("]d", function()
      vim.diagnostic.jump({ count = 1, float = true })
    end, { desc = "Go to Next Diagnostic" })

    vim.keymap.set(
      { "n", "v" },
      "<leader>a",
      vim.lsp.buf.code_action,
      { desc = "Code Actions" }
    )
  end,
})

local servers = {
  "astro",
  "clangd",
  "jsonls",
  "marksman",
  "gopls",
  "lua_ls",
  "svelte",
  "vtsls",
  "tailwindcss",
}

local icons = { ERROR = " ", WARN = " ", HINT = "󰠠 ", INFO = " " }

vim.diagnostic.config({
  float = {
    source = true,
    severity_sort = true,
    prefix = function(diagnostic)
      local level = vim.diagnostic.severity[diagnostic.severity]
      local prefix = string.format(" %s ", icons[level])
      return prefix, "Diagnostic" .. level:gsub("^%l", string.upper)
    end,
  },
  virtual_text = {
    prefix = "",
    spacing = 2,
    format = function(diagnostic)
      local icon = icons[vim.diagnostic.severity[diagnostic.severity]]
      return string.format("%s %s ", icon, diagnostic.message)
    end,
  },
  signs = false,
})

return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "folke/neoconf.nvim",
    { "j-hui/fidget.nvim", opts = {} },
    { "folke/lazydev.nvim", opts = {}, ft = "lua" },
  },
  config = function()
    local lsp_config = require("lspconfig")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

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
