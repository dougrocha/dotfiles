return {
    'saghen/blink.cmp',
    lazy = false,
    dependencies = {
        { 'nvim-mini/mini.snippets' },
        { 'saghen/blink.compat', version = '2.*', lazy = true, opts = {} },
    },
    build = 'cargo +nightly build --release',
    ---@module 'blink-cmp'
    ---@type blink.cmp.Config
    opts = {
        keymap = {
            ['<C-n>'] = { 'select_next', 'fallback' },
            ['<C-p>'] = { 'select_prev', 'fallback' },
            ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
            ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
            ['<C-l>'] = { 'snippet_forward', 'fallback' },
            ['<C-h>'] = { 'snippet_backward', 'fallback' },
            ['<C-e>'] = { 'hide', 'fallback' },
            ['<CR>'] = { 'accept', 'fallback' },
        },
        appearance = {
            use_nvim_cmp_as_default = true,
            nerd_font_variant = 'mono',
        },
        completion = {
            documentation = {
                auto_show = true,
            },
            list = {
                selection = { preselect = false, auto_insert = true },
            },
        },
        snippets = {
            preset = 'mini_snippets',
        },
        sources = {
            default = { 'lsp', 'path', 'snippets', 'buffer' },
        },
    },
}
