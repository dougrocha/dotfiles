-----------------------------------------------------------
-- Telescope configuration file
-----------------------------------------------------------

-- Plugin: Telescope
-- url: https://github.com/nvim-telescope/telescope.nvim

local status_ok, telescope = pcall(require, 'telescope')
if not status_ok then
    return
end

local actions = require("telescope.actions")

telescope.setup {
    defaults = {
        file_ignore_patterns = { "node_modules" },
        mappings = {
            n = {
                ["<esc>"] = actions.close
            },
            i = {
                ["<C-h>"] = "which_key"
            }
        },
    },
    pickers = {
        find_files = {
            theme = "dropdown",
        }
    },
}
