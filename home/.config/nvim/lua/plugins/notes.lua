local function find_resources()
    local resources_path = vim.env.ZK_NOTEBOOK_DIR .. '/resources'

    require('fzf-lua').fzf_exec(vim.fn.globpath(resources_path, '*', 0, 1), {
        prompt = 'Select Resource> ',
        previewer = false,
        actions = {
            ['default'] = function(selected)
                local resource_file = selected[1]
                vim.cmd('Open ' .. resource_file)
            end,
        },
    })
end

local function pick_school_notes()
    local areas_path = vim.env.ZK_NOTEBOOK_DIR .. '/school'

    require('fzf-lua').fzf_exec(vim.fn.globpath(areas_path, '*', 0, 1), {
        prompt = 'Select Class> ',
        previewer = false,
        actions = {
            ['default'] = function(selected)
                local class_folder = selected[1]

                require('zk.commands').get 'ZkNotes' { hrefs = { class_folder } }
            end,
        },
    })
end

return {
    {
        'obsidian-nvim/obsidian.nvim',
        version = '*', -- recommended, use latest release instead of latest commit
        ft = 'markdown',
        -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
        event = {
            --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
            --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
            --   -- refer to `:h file-pattern` for more examples
            'BufReadPre '
                .. vim.fn.expand '~'
                .. '/second-brain/*.md',
            'BufNewFile ' .. vim.fn.expand '~' .. '/second-brain/*.md',
        },
        enabled = function()
            return not vim.g.minifiles_active
        end,
        ---@module 'obsidian'
        ---@type obsidian.config
        opts = {
            workspaces = {
                {
                    name = 'second-brain',
                    path = vim.fn.expand '~' .. '/second-brain',
                },
            },
            legacy_commands = false,
            notes_subdir = 'index',
            completion = {
                nvim_cmp = false,
                blink = true,
            },
            picker = {
                name = 'fzf-lua',
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
                return tostring(os.time()) .. '-' .. suffix
            end,

            ui = {
                enable = false,
            },
        },
    },
    {
        'zk-org/zk-nvim',
        enabled = false,
        event = 'VeryLazy',
        opts = {
            picker = 'fzf_lua',
        },
        keys = {
            { '<leader>zc', pick_school_notes, desc = 'Select Class & Open Note' },
            { '<leader>zr', find_resources, desc = 'Open resource' },
            {
                '<leader>zn',
                function()
                    require('zk').new { title = vim.fn.input 'Title: ' }
                end,
                desc = 'New Note',
            },
            { '<leader>zf', '<cmd>ZkNotes { sort = { "modified" } }<CR>', desc = 'Find Notes' },
            { '<leader>zt', '<cmd>ZkTags<CR>', desc = 'Search by Tag' },
            { '<leader>zl', '<cmd>ZkLinks<CR>', desc = 'Follow Link' },
            { '<leader>zb', '<cmd>ZkBack<CR>', desc = 'Go Back' },
            { '<leader>zi', '<cmd>ZkInsertLink<CR>', desc = 'Insert Link' },
            {
                '<leader>znt',
                ":ZkNewFromTitleSelection { dir = vim.fn.expand('%:p:h') }<CR>",
                desc = 'New note from title',
                mode = 'v',
            },
            {
                '<leader>znc',
                ":ZkNewFromContentSelection { dir = vim.fn.expand('%:p:h'), title = vim.fn.input('Title: ') }<CR>",
                desc = 'New note from content',
                mode = 'v',
            },
        },
        config = function(_, opts)
            require('zk').setup(opts)
        end,
    },
}
