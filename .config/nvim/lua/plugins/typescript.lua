return {
  "pmizio/typescript-tools.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "neovim/nvim-lspconfig",
    "dmmulroy/ts-error-translator.nvim",
  },
  config = function()
    local api = require("typescript-tools.api")

    require("typescript-tools").setup({
      settings = {
        seperate_diagnostic_server = true,
        expose_as_code_action = "all",
        tsserver_mas_memory = "auto",
        complete_function_calls = true,
        include_completions_with_insert_text = true,
        tsserver_file_preferences = {
          includeInlayParameterNameHints = "all", -- "none" | "literals" | "all";
          includeInlayParameterNameHintsWhenArgumentMatchesName = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayVariableTypeHintsWhenArgumentMatchesName = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
          includeCompletionEntryDetails = true,
          quotePreference = "auto",
        },
      },
      handlers = {
        ["textDocument/publishDiagnostics"] = api.filter_diagnostics({ 6133 }),
      },
    })
  end,
}
