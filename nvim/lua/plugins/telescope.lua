return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  cmd = "Telescope",
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
  keys = {
    { "<leader>/", "<cmd>Telescope live_grep<CR>", desc = "Grep workspace" },
    { "<leader>fw", "<cmd>Telescope grep_string<CR>", desc = "Find word under cursor" },
    { "<leader>fu", "<cmd>Telescope undo<CR>", desc = "Find undo Tree" },
    { "<leader><leader>", "<cmd>Telescope buffers<CR>", desc = "Find existing buffers" },
    { "<C-f>", "<cmd>Telescope current_buffer_fuzzy_find<CR>", desc = "Find in current buffer" },

    { "<leader>sk", "<cmd>Telescope keymaps<CR>", desc = "Search Keymaps" },
    { "<leader>sh", "<cmd>Telescope help_tags<CR>", desc = "Search Help" },
    { "<leader>sd", "<cmd>Telescope diagnostics<CR>", desc = "Search buffer diagnostics" },
    { "<leader>sf", "<cmd>Telescope find_files<CR>", desc = "Search files" },
    { "<leader>sD", "<cmd>Telescope diagnostics<CR>", desc = "Search Workspace Diagnostics" },
    { "<leader>ss", "<cmd>Telescope spell_suggest<CR>", desc = "Spell suggestions" },
    { "<leader>s.", "<cmd>Telescope oldfiles<CR>", desc = "Search recently opened files" },
    { "<C-P>", "<cmd>Telescope git_files<CR>", desc = "Search git files" },
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
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
      defaults = {
        prompt_prefix = " ",
        selection_caret = " ",
        mappings = {
          i = {
            ["<C-j>"] = actions.cycle_history_next,
            ["<C-k>"] = actions.cycle_history_prev,

            ["<C-f>"] = actions.preview_scrolling_down,
            ["<C-b>"] = actions.preview_scrolling_up,

            ["<C-d>"] = actions.delete_buffer,

            ["C-w"] = actions.send_selected_to_qflist + actions.open_qflist,

            ["<C-c>"] = actions.close,
          },
          n = {
            ["<C-d>"] = actions.delete_buffer,

            ["C-w"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<C-c>"] = actions.close,
          },
        },
        file_ignore_patterns = { "node_modules", ".git" },
        path_display = { "smart" },
        layout_config = {
          height = 0.4,
          width = 0.6,
          prompt_position = "top",
          preview_cutoff = 120,
        },
      },
      pickers = {
        find_files = {
          preview = false,
          no_ignore = false,
          hidden = false,
        },
        oldfiles = {
          cwd_only = true,
        },
        buffers = {
          sort_lastused = true,
          ignore_current_buffer = true,
        },
        live_grep = {
          only_sort_text = true,
          preview = true,
        },
      },
    })

    telescope.load_extension("fzf")
    telescope.load_extension("undo")
    telescope.load_extension("ui-select")
  end,
}
