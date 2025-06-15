return {
    'yetone/avante.nvim',
    event = 'VeryLazy',
    version = false,
    dependencies = {
        'nvim-treesitter/nvim-treesitter',
        'stevearc/dressing.nvim',
        'nvim-lua/plenary.nvim',
        'MunifTanjim/nui.nvim',
        'zbirenbaum/copilot.lua',
    },
    ---@module 'avante'
    ---@type avante.CoreConfig
    ---@diagnostic disable-next-line: missing-fields
    opts = {
        provider = 'copilot',
        providers = {
            copilot = {
                endpoint = 'https://api.githubcopilot.com/',
                model = 'gpt-4o-mini',
            },
            ['copilot:claude-3.7-thought'] = {
                __inherited_from = 'copilot',
                model = 'claude-3.7-sonnet-thought',
            },
            ['copilot:claude-3.7'] = {
                __inherited_from = 'copilot',
                model = 'claude-3.7-sonnet',
            },
            ['copilot:claude-3.5'] = {
                __inherited_from = 'copilot',
                model = 'claude-3.5-sonnet',
            },
            ['copilot:gpt-4.1'] = {
                __inherited_from = 'copilot',
                model = 'gpt-4.1',
            },
            ['copilot:gpt-4o-mini'] = {
                __inherited_from = 'copilot',
                model = 'gpt-4o-mini',
            },
            ['copilot:gpt-4o'] = {
                __inherited_from = 'copilot',
                model = 'gpt-4o',
            },
        },
        hints = { enabled = false },
    },
}
