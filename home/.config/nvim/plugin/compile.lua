local add = require('pack').add

add {
    { 'nvim-lua/plenary.nvim', setup = false },
    {
        'ej-shafran/compile-mode.nvim',
        setup = false,
        on_setup = function()
            ---@module "compile-mode"
            ---@type CompileModeOpts
            vim.g.compile_mode = {
                default_command = {
                    rust = 'cargo run',
                },
                recompile_no_fail = false,
            }

            vim.keymap.set('n', '<leader>R', '<cmd>below Compile<CR>', { desc = 'Compile' })
            vim.keymap.set('n', '<leader>r', '<cmd>below Recompile<CR>', { desc = 'Re-compile' })
        end,
    },
}
