return {
    {
        'Bekaboo/dropbar.nvim',
        opts = {},
    },
    {
        'j-hui/fidget.nvim',
        event = { 'BufReadPre', 'BufNewFile' },
        opts = {
            notification = {
                window = { winblend = 0 },
            },
        },
    },
}
