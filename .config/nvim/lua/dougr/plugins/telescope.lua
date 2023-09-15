return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    opts = {
      extensions = {
        theme = "tokyonight-storm",
      },
    },
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local builtin = require("telescope.builtin")

    telescope.setup({
      defaults = {
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
          },
        },
      },
    })

    telescope.load_extension("fzf")
    telescope.load_extension("harpoon")

    local keymap = vim.keymap

    keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[F]uzzy [F]ind files in cwd" })
    keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "[F]uzzy find [R]ecent files" })
    keymap.set("n", "<leader>fs", builtin.live_grep, { desc = "[F]ind [S]tring in cwd" })
    keymap.set("n", "<leader>fc", builtin.grep_string, { desc = "[F]ind [C]urrent word" })
  end,
}
