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

                require('zk.commands').get('ZkNotes')({ hrefs = { class_folder } })
            end,
        },
    })
end

return {
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
                    require('zk').new({ title = vim.fn.input('Title: ') })
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
    {
        'iamcco/markdown-preview.nvim',
        cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
        ft = { 'markdown' },
        build = 'cd app && npm install && git restore .',
        init = function()
            vim.g.mkdp_filetypes = { 'markdown' }
        end,
        keys = {
            {
                '<leader>cp',
                ft = 'markdown',
                '<cmd>MarkdownPreviewToggle<cr>',
                desc = 'Markdown Preview',
            },
        },
    },
    {
        'MeanderingProgrammer/render-markdown.nvim',
        enabled = false,
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' },
        ft = { 'Avante' },
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {
            overrides = {
                buftype = {
                    nofile = {
                        enabled = false,
                    },
                },
            },
            file_types = { 'Avante' },
            completions = {
                blink = { enabled = true },
                lsp = { enabled = true },
            },
            code = {
                sign = false,
                width = 'block',
                right_pad = 1,
            },
            heading = {
                sign = false,
                icons = {},
            },
            latex = {
                enabled = false,
            },
        },
    },
}
