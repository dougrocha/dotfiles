-----------------------------------------------------------
-- Autocommand functions
-----------------------------------------------------------

-- Define autocommands with Lua APIs
-- See: h:api-autocmd, h:augroup

local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

-- Don't auto commenting new lines
autocmd('BufEnter', {
  pattern = '*',
  command = 'set fo-=c fo-=r fo-=o'
})

-- Remove whitespace on save
autocmd('BufWritePre', {
  pattern = '*',
  command = ":%s/\\s\\+$//e"
})

-- Turn off paste mode when leaving insert
autocmd('InsertLeave', {
  pattern = '*',
  command = 'set nopaste'
})

-- Settings for filetypes:
-- Disable line length marker
augroup('setLineLength', { clear = true })
autocmd('Filetype', {
  group = 'setLineLength',
  pattern = { 'text', 'markdown', 'javascript', 'typescript' },
  command = 'setlocal cc=0'
})

-- Set indentation to 2 spaces
augroup('setIndent', { clear = true })
autocmd('Filetype', {
  group = 'setIndent',
  pattern = { 'xml', 'html', 'css', 'javascript', 'typescript',
    'yaml', 'lua'
  },
  command = 'setlocal shiftwidth=2 tabstop=2'
})

-- Custom Autocomplete
-- autocmd(
-- { "TextChangedI", "TextChangedP" },
-- {
--   callback = function()
--     local line = vim.api.nvim_get_current_line()
--     local cursor = vim.api.nvim_win_get_cursor(0)[2]

--     local current = string.sub(line, cursor, cursor + 1)
--     if current == "." or current == "," or current == " " then
--       require('cmp').close()
--     end

--     local before_line = string.sub(line, 1, cursor + 1)
--     local after_line = string.sub(line, cursor + 1, -1)
--     if not string.match(before_line, '^%s+$') then
--       if after_line == "" or string.match(before_line, " $") or string.match(before_line, "%.$") then
--         require('cmp').complete()
--       end
--     end
--   end,
--   pattern = "*"
-- })
