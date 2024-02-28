return {
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    version = "*",
    opts = {},
  },
  {
    "echasnovski/mini.surround",
    event = "VeryLazy",
    version = "*",
    opts = {},
  },
  {
    "echasnovski/mini.statusline",
    event = "VeryLazy",
    version = "*",
    opts = {},
  },
  {
    "echasnovski/mini.statusline",
    event = "VeryLazy",
    version = "*",
    opts = {},
  },
  {
    "echasnovski/mini.comment",
    event = "VeryLazy",
    version = "*",
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    config = function()
      require("mini.comment").setup({
        options = {
          custom_commentstring = function()
            return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
          end,
        },
      })
    end,
  },
  {
    "echasnovski/mini.bufremove",
    event = "VeryLazy",
    version = "*",
    opts = {},
    keys = {
      {
        "<leader>bd",
        function()
          local bd = require("mini.bufremove").delete
          if vim.bo.modified then
            local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
            if choice == 1 then -- Yes
              vim.cmd.write()
              bd(0)
            elseif choice == 2 then -- No
              bd(0, true)
            end
          else
            bd(0)
          end
        end,
        desc = "Delete Buffer",
      },
      {
        "<leader>bD",
        function()
          require("mini.bufremove").delete(0, true)
        end,
        desc = "Delete Buffer (Force)",
      },
    },
  },
}
