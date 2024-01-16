return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
  opts = {
    lsp = {
      -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
    },
    -- you can enable a preset for easier configuration
    presets = {
      bottom_search = true, -- use a classic bottom cmdline for search
      command_palette = true, -- position the cmdline and popupmenu together
      long_message_to_split = true, -- long messages will be sent to a split
      inc_rename = false, -- enables an input dialog for inc-rename.nvim
      lsp_doc_border = false, -- add a border to hover docs and signature help
    },
    routes = {
      {
        filter = {
          event = "msg_show",
          any = {
            { find = "%d+L, %d+B" },
            { find = "; after #%d+" },
            { find = "; before #%d+" },
          },
        },
        view = "mini",
      },
    },
  },
  config = function(_, opts)
    local noice = require("noice")

    noice.setup(opts)

    -- local wk = require("which-key")
    -- wk.register({
    --   ["<leader>sn"] = {
    --     name = "+noice",
    --     l = {
    --       function()
    --         noice.cmd("last")
    --       end,
    --       "Last Message",
    --     },
    --     h = {
    --       function()
    --         noice.cmd("history")
    --       end,
    --       "Noice History",
    --     },
    --     a = {
    --       function()
    --         noice.cmd("all")
    --       end,
    --       "All",
    --     },
    --     d = {
    --       function()
    --         noice.cmd("dismiss")
    --       end,
    --       "Dismiss All",
    --     },
    --   },
    -- })
  end,
}
