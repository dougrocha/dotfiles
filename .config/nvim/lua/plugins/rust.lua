return {
  "mrcjkb/rustaceanvim",
  version = "^3",
  ft = { "rust" },
  config = function()
    local bufnr = vim.api.nvim_get_current_buf()

    vim.keymap.set("n", "<leader>ca", function()
      vim.cmd.RustLsp("codeAction")
    end, { silent = true, buffer = bufnr })
  end,
}
