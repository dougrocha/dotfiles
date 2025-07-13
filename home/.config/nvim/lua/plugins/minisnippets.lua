return {
    'echasnovski/mini.snippets',
    version = false,
    event = 'InsertEnter',
    opts = function()
        local gen_loader = require('mini.snippets').gen_loader
        local lang_patterns = {
            tsx = { 'typescript.json' },
        }
        return {
            snippets = {
                gen_loader.from_lang { lang_patterns = lang_patterns },
            },
        }
    end,
}
