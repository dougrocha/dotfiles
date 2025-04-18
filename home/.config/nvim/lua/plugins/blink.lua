return {
    'saghen/blink.cmp',
    event = 'InsertEnter',
    dependencies = {
        'echasnovski/mini.snippets',
        {
            'folke/lazydev.nvim',
            opts = { library = { { path = '${3rd}/luv/library', words = { 'vim%.uv' } } } },
            ft = 'lua',
        },
    },
    version = '*',
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
            default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
            providers = {
                lazydev = {
                    name = 'LazyDev',
                    module = 'lazydev.integrations.blink',
                    score_offset = 100,
                },
            },
        },
    },
}
