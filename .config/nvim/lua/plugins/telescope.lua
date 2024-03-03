return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  cmd = "Telescope",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      cond = function()
        return vim.fn.executable("make") == 1
      end,
    },
    "nvim-telescope/telescope-ui-select.nvim",
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
        ["ui-select"] = {
          require("telescope.themes").get_dropdown({}),
        },
        fzf = {
          fuzzy = true, -- false will only do exact matching
          override_generic_sorter = true, -- override the generic sorter
          override_file_sorter = true, -- override the file sorter
          case_mode = "smart_case", -- or "ignore_case" or "respect_case"
        },
      },
    })

    telescope.load_extension("fzf")
    telescope.load_extension("undo")
    telescope.load_extension("ui-select")

    local builtin = require("telescope.builtin")

    local wk = require("which-key")
    wk.register({
      ["<leader>/"] = { builtin.live_grep, "Grep workspace" },
      ["<leader>fw"] = { builtin.grep_string, "Find word under cursor" },
      ["<leader>fu"] = { "<cmd>Telescope undo<CR>", "Find undo Tree" },

      ["<leader><leader>"] = {
        function()
          builtin.buffers({
            sort_lastused = true,
            ignore_current_buffer = true,
          })
        end,
        "Find existing buffers",
      },
    })

    wk.register({
      ["<leader>sk"] = { builtin.keymaps, "Search Keymaps" },
      ["<leader>sh"] = { builtin.help_tags, "Search Help" },
      ["<leader>sd"] = {
        function()
          builtin.diagnostics({ bufnr = 0 })
        end,
        "Search buffer diagnostics",
      },
      ["<leader>sf"] = { builtin.find_files, "Find files" },
      ["<leader>sD"] = { builtin.diagnostics, "Search Workspace Diagnostics" },
      ["<leader>ss"] = { builtin.spell_suggest, "Spell suggestions" },
      ["<leader>s."] = { builtin.oldfiles, "Find recently openened files" },
    })
  end,
}
