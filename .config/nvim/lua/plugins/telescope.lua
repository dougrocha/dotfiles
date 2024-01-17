return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
    "nvim-telescope/telescope-ui-select.nvim",
    "debugloop/telescope-undo.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      file_ignore_patterns = { "%.git/." },
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
      },
      pickers = {
        find_files = {
          previewer = false,
          layout_config = {
            height = 0.4,
            prompt_position = "top",
            preview_cutoff = 120,
          },
        },
        git_files = {
          previewer = false,
          layout_config = {
            height = 0.4,
            prompt_position = "top",
            preview_cutoff = 120,
          },
        },
        buffers = {
          mappings = {
            i = {
              ["<C-d>"] = actions.delete_buffer,
            },
            n = {
              ["<C-d>"] = actions.delete_buffer,
            },
          },
        },
        current_buffer_fuzzy_find = {
          previewer = true,
          layout_config = {
            prompt_position = "top",
            preview_cutoff = 120,
          },
        },
        live_grep = {
          only_sort_text = true,
          previewer = true,
        },
        grep_string = {
          only_sort_text = true,
          previewer = true,
        },
      },
      extensions = {
        fzf = {
          fuzzy = true, -- false will only do exact matching
          override_generic_sorter = true, -- override the generic sorter
          override_file_sorter = true, -- override the file sorter
          case_mode = "smart_case", -- or "ignore_case" or "respect_case"
        },
      },
    })

    local builtin = require("telescope.builtin")

    telescope.load_extension("fzf")
    telescope.load_extension("undo")
    telescope.load_extension("ui-select")

    local wk = require("which-key")
    wk.register({
      ["<leader>/"] = {
        function()
          builtin.live_grep()
        end,
        "Grep",
      },
      ["<leader>fb"] = {
        function()
          builtin.buffers({
            sort_lastused = true,
            ignore_current_buffer = true,
            show_all_buffers = true,
          })
        end,
        "Show buffers",
      },
      ["<leader>ff"] = {
        function()
          builtin.find_files({
            no_ignore = false,
            hidden = true,
          })
        end,
        "Find files",
      },
      ["<leader>fr"] = {
        function()
          builtin.oldfiles()
        end,
        "Recent files",
      },
      ["<leader>fP"] = {
        function()
          builtin.find_files({
            cwd = require("lazy.core.config").options.root,
          })
        end,
        "File Plugin File",
      },
      ["<leader>fw"] = {
        function()
          builtin.grep_string()
        end,
        "Grep word under cursor",
      },
      ["<leader>fu"] = { "<cmd>Telescope undo<cr>", "Undo Tree" },
    })

    wk.register({
      ["<leader>be"] = { "<cmd>Telescope buffers<cr>", "Show buffers" },
    })

    wk.register({
      ["<leader>sk"] = { "<cmd>Telescope keymaps<cr>", "Key Maps" },
      ["<leader>sd"] = { "<cmd>Telescope diagnostics bufnr=0<cr>", "Document diagnostics" },
      ["<leader>sh"] = { "<cmd>Telescope help_tags<cr>", "Help" },
      ["<leader>sD"] = { "<cmd>Telescope diagnostics<cr>", "Workspace diagnostics" },
      ["<leader>ss"] = { builtin.spell_suggest, "Spell suggestions" },
    })
  end,
}
