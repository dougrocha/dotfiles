return {
  "saecki/crates.nvim",
  event = { "BufRead Cargo.toml" },
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    popup = {
      border = "rounded",
    },
    -- keys = {
    --   hide = { "q", "<esc>" },
    --   open_url = { "<cr>" },
    --   select = { "<cr>" },
    --   select_alt = { "s" },
    --   toggle_feature = { "<cr>" },
    --   copy_value = { "yy" },
    --   goto_item = { "gd", "K", "<C-LeftMouse>" },
    --   jump_forward = { "<c-i>" },
    --   jump_back = { "<c-o>", "<C-RightMouse>" },
    -- },
  },
  config = function(_, opts)
    require("crates").setup(opts)

    local cmp = require("cmp")
    vim.api.nvim_create_autocmd("BufRead", {
      group = vim.api.nvim_create_augroup("CmpSourceCargo", { clear = true }),
      pattern = "Cargo.toml",
      callback = function()
        cmp.setup.buffer({ sources = { { name = "crates" } } })
      end,
    })

    local function show_documentation()
      local filetype = vim.bo.filetype
      if vim.tbl_contains({ "vim", "help" }, filetype) then
        vim.cmd("h " .. vim.fn.expand("<cword>"))
      elseif vim.tbl_contains({ "man" }, filetype) then
        vim.cmd("Man " .. vim.fn.expand("<cword>"))
      elseif vim.fn.expand("%:t") == "Cargo.toml" and require("crates").popup_available() then
        require("crates").show_popup()
      else
        vim.lsp.buf.hover()
      end
    end

    vim.keymap.set("n", "<leader>k", show_documentation, { desc = "Show package details", silent = true })
  end,
}
