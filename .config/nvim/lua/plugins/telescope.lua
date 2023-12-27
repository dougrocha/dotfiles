return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      cond = function()
        return vim.fn.executable("make") == 1
      end,
    },
    "nvim-tree/nvim-web-devicons",
    "debugloop/telescope-undo.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      defaults = {
        prompt_prefix = " ",
        selection_caret = " ",
        -- open files in the first window that is an actual file.
        -- use the current window if no other window is available.
        get_selection_window = function()
          local wins = vim.api.nvim_list_wins()
          table.insert(wins, 1, vim.api.nvim_get_current_win())
          for _, win in ipairs(wins) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].buftype == "" then
              return win
            end
          end
          return 0
        end,
        mappings = {
          i = {
            ["<C-j>"] = actions.cycle_history_next,
            ["<C-k>"] = actions.cycle_history_prev,
            ["<C-f>"] = actions.preview_scrolling_down,
            ["<C-b>"] = actions.preview_scrolling_up,

            ["C-w"] = actions.send_selected_to_qflist + actions.open_qflist,
          },
          n = {
            ["C-w"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["q"] = actions.close,
          },
        },
        file_ignore_patterns = { "node_modules", ".git" },
        path_display = { "smart" },
        pickers = {
          find_files = {
            find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
            hidden = true,
          },
        },
      },
    })

    local builtin = require("telescope.builtin")

    telescope.load_extension("fzf")
    telescope.load_extension("undo")

    local keymap = vim.keymap

    keymap.set("n", "<leader>/", "<cmd>Telescope live_grep<cr>", { desc = "Grep" })
    keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
    keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Recent files" })
    keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Document symbols" })
    keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "Grep word under cursor" })
    keymap.set("n", "<leader>fu", "<cmd>Telescope undo<cr>", { desc = "Undo Tree" })

    keymap.set("n", "<leader>sk", "<cmd>Telescope keymaps<cr>", { desc = "Key Maps" })
    keymap.set("n", "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", { desc = "Document diagnostics" })
    keymap.set("n", "<leader>sD", "<cmd>Telescope diagnostics<cr>", { desc = "Workspace diagnostics" })
    keymap.set("n", "<leader>sk", "<cmd>Telescope keymaps<cr>", { desc = "Key Maps" })
    keymap.set("n", "<leader>ss", builtin.spell_suggest, { desc = "Spell suggestions" })
  end,
}
