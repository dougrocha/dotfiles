-- Only TypeScript 7+ tsc has --lsp, so older project installs fall back to the global one.
---@param root string
---@return boolean
local function has_native_tsc(root)
    local ok, pkg = pcall(function()
        local path = vim.fs.joinpath(root, 'node_modules/typescript/package.json')
        return vim.json.decode(table.concat(vim.fn.readfile(path), '\n'))
    end)
    local major = ok and type(pkg) == 'table' and tonumber(tostring(pkg.version):match '^(%d+)%.')
    return type(major) == 'number' and major >= 7
end

---@type vim.lsp.Config
return {
    cmd = function(dispatchers, config)
        local cmd = 'tsc'
        if (config or {}).root_dir then
            local local_cmd = vim.fs.joinpath(config.root_dir, 'node_modules/.bin', cmd)
            if vim.fn.executable(local_cmd) == 1 and has_native_tsc(config.root_dir) then
                cmd = local_cmd
            end
        end
        return vim.lsp.rpc.start({ cmd, '--lsp', '--stdio' }, dispatchers)
    end,
    filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    root_dir = function(bufnr, on_dir)
        local root_markers = { { 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lock' }, { '.git' } }

        local project_root = vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()

        on_dir(project_root)
    end,
}