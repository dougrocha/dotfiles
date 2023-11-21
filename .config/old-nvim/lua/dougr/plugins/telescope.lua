return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
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
    keymap.set("n", "<leader>ss", builtin.spell_suggest, { desc = "[S]earch [S]pell" })
    keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
    keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
    keymap.set("n", "<leader>fb", builtin.buffers, { desc = "[F]ind existing [B]uffers" })
    keymap.set(
      "n",
      "<leader>/",
      function() builtin.current_buffer_fuzzy_find() end,
      { desc = "[/] Fuzzy find in current buffer" }
    )
  end,
}
