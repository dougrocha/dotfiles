return {
    'ej-shafran/compile-mode.nvim',
    branch = 'latest',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
        { '<leader>R', '<cmd>below Compile<CR>', desc = 'Compile' },
        { '<leader>r', '<cmd>below Recompile<CR>', desc = 'Re-compile' },
    },
    config = function()
        ---@module "compile-mode"
        ---@type CompileModeOpts
        vim.g.compile_mode = {
            default_command = {
                rust = 'cargo run',
            },
            recompile_no_fail = false,
        }
    end,
}
