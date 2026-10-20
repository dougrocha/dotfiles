--- Thanks you! @url https://github.com/XavierChanth/dotfiles/blob/trunk/dotfiles/dot-config/nvim/lua/util/clangd.lua#L8

---@class util.clangd
local M = {}

local function get_client(bufnr)
    return vim.lsp.get_clients({ bufnr = bufnr, name = 'clangd' })[1]
end

function M.switch_source_header(bufnr)
    local method_name = 'textDocument/switchSourceHeader'
    bufnr = (bufnr == 0 and vim.api.nvim_get_current_buf()) or bufnr
    local client = get_client(bufnr)

    if not client then
        return vim.notify(
            ('method %s is not supported by any servers active on the current buffer'):format(method_name)
        )
    end
    local params = vim.lsp.util.make_text_document_params(bufnr)
    client:request(method_name, params, function(err, result)
        if err then
            error(tostring(err))
        end
        if not result then
            vim.notify 'corresponding file cannot be determined'
            return
        end
        vim.cmd.edit(vim.uri_to_fname(result))
    end, bufnr)
end

return M
