-- Cute code action floating window.
return {
    'rachartier/tiny-code-action.nvim',
    lazy = true,
    opts = {
        picker = {
            'buffer',
            opts = { hotkeys = true },
        },
    },
}
