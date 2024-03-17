return {
  {
    "echasnovski/mini.ai",
    event = "BufReadPre",
    version = "*",
    opts = { n_lines = 500 },
  },
  {
    "echasnovski/mini.surround",
    event = "BufReadPre",
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
    "echasnovski/mini.bufremove",
    event = "BufReadPre",
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
