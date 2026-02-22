return {
    'ThePrimeagen/99',
    config = function()
        local _99 = require '99'

        ---@type _99.Options
        _99.setup {
            model = 'anthropic/claude-sonnet-4-5',
            completion = {
                custom_rules = {
                    '.agents/skills/',
                },
                source = 'blink',
            },
            md_files = {
                'AGENT.md',
            },
        }

        vim.keymap.set('v', '<leader>9v', function()
            _99.visual()
        end)

        vim.keymap.set('n', '<leader>9s', function()
            _99.search()
        end)
    end,
}
