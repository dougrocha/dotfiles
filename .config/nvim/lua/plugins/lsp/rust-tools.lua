return {
  "simrat39/rust-tools.nvim",
  config = function()
    require("rust-tools").setup({
      server = {
        on_attach = function(_, bufnr)
          local opts = { buffer = bufnr, noremap = true, silent = true }
          -- Hover Actions
          opts.desc = "Show Hover Actions"
          vim.keymap.set("n", "<leader>k", "<cmd>RustHoverActions<CR>", opts)
          -- Code Actions
          opts.desc = "Show Code Actions"
          vim.keymap.set({ "n", "v" }, "<leader>ca", "<cmd>RustCodeAction<CR>", opts)
        end,
      },
    })
  end,
}
