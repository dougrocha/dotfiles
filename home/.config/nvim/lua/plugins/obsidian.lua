return {
    'obsidian-nvim/obsidian.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
    version = '*',
    ft = 'markdown',
    cmd = 'Obsidian',
    ---@module 'obsidian'
    ---@type obsidian.config
    opts = {
        legacy_commands = false,
        workspaces = {
            {
                name = 'second-brain',
                path = '~/second-brain',
            },
        },
        notes_subdir = 'inbox',
        templates = {
            folder = 'templates',
            date_format = '%Y-%m-%d',
        },
        ---@param title string|?
        ---@return string
        note_id_func = function(title)
            local suffix = ''
            if title ~= nil then
                -- If title is given, transform it into valid file name.
                suffix = title:gsub(' ', '-'):gsub('[^A-Za-z0-9-]', ''):lower()
            else
                -- If title is nil, just add 4 random uppercase letters to the suffix.
                for _ = 1, 4 do
                    suffix = suffix .. string.char(math.random(65, 90))
                end
            end
            return suffix .. '.md'
        end,
        ---@diagnostic disable-next-line: missing-fields
        ui = {
            enable = false,
        },
    },
}
