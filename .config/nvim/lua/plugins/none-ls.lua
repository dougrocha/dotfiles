return {
  "nvimtools/none-ls.nvim", -- configure formatters & linters
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "jay-babu/mason-null-ls.nvim",
    "nvim-lua/plenary.nvim",
  },
  config = function()
    -- import null-ls plugin
    local null_ls = require("null-ls")

    local null_ls_utils = require("null-ls.utils")

    local mason_null_ls = require("mason-null-ls")
    mason_null_ls.setup({
      ensure_installed = {
        "cland-format",
        "prettierd",
        "stylua",
        "eslint_d",
        "markdownlint",
      },
    })

    -- for conciseness
    local formatting = null_ls.builtins.formatting -- to setup formatters
    local diagnostics = null_ls.builtins.diagnostics -- to setup linters
    local code_actions = null_ls.builtins.code_actions

    -- to setup format on save
    local augroup = vim.api.nvim_create_augroup("LspFormatting", {
      clear = false,
    })

    -- configure null_ls
    null_ls.setup({
      -- add package.json as identifier for root (for typescript monorepos)
      root_dir = null_ls_utils.root_pattern(".null-ls-root", "Makefile", ".git", "package.json"),

      timeout = 2000,
      log_level = "debug",
      -- setup formatters & linters
      sources = {
        formatting.clang_format, -- c/c++ formatter
        formatting.prettierd.with({
          extra_filetypes = { "svelte", "toml" },
        }),
        diagnostics.eslint_d.with({
          condition = function(utils)
            return utils.root_has_file({ ".eslintrc.js", ".eslintrc.json" })
          end,
        }), -- js/ts linter
        code_actions.eslint_d, -- js/ts code actions

        formatting.markdownlint, -- markdown formatter
        diagnostics.markdownlint, -- markdown linter

        formatting.stylua, -- lua formatter
      },
      -- configure format on save
      on_attach = function(current_client, bufnr)
        if current_client.supports_method("textDocument/formatting") then
          vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({
                filter = function(client)
                  --  only use null-ls for formatting instead of lsp server
                  return client.name == "null-ls"
                end,
                bufnr = bufnr,
              })
            end,
          })
        end
      end,
    })
  end,
}
