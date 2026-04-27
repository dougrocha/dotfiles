return {
    dir = '~/dev/keytrack.nvim',
    cmd = 'KeyTrack',
    opts = {
        keymaps = {
            -- File finding
            { key = '<leader>ff', desc = 'Find files' },
            { key = '<leader>fr', desc = 'Recent files' },
            { key = '<leader>/',  desc = 'Live grep' },
            { key = '<leader>fb', desc = 'Find in buffer' },

            -- LSP
            { key = 'gd',  desc = 'Go to definition' },
            { key = 'gD',  desc = 'Peek definition' },
            { key = 'grr', desc = 'References' },
            { key = 'gra', desc = 'Code actions' },
            { key = 'gy',  desc = 'Go to type definition' },
            { key = 'K',   desc = 'Hover' },

            -- Diagnostics
            { key = '[d', desc = 'Prev diagnostic' },
            { key = ']d', desc = 'Next diagnostic' },
            { key = '[e', desc = 'Prev error' },
            { key = ']e', desc = 'Next error' },

            -- Harpoon
            { key = '<leader>h', desc = 'Harpoon mark' },
            { key = '<C-e>',     desc = 'Harpoon menu' },
            { key = '<Space>1',  desc = 'Harpoon 1' },
            { key = '<Space>2',  desc = 'Harpoon 2' },
            { key = '<Space>3',  desc = 'Harpoon 3' },

            -- Git
            { key = '[g',         desc = 'Prev hunk' },
            { key = ']g',         desc = 'Next hunk' },
            { key = '<leader>gs', desc = 'Stage hunk' },
            { key = '<leader>gb', desc = 'Blame line' },
            { key = '<leader>gp', desc = 'Preview hunk' },

            -- Motion
            { key = 's', desc = 'Flash jump' },

            -- Misc
            { key = '<leader>bd', desc = 'Delete buffer' },
            { key = '<leader>e',  desc = 'File explorer' },
            { key = '<leader>xq', desc = 'Toggle quickfix' },
        },
    },
}
