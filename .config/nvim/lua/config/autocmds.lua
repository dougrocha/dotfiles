local function augroup(name)
  return vim.api.nvim_create_augroup(name, { clear = true })
end

-- Highlight when yanking a line
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank({
      higroup = "IncSearch",
      timeout = 200,
    })
  end,
})
