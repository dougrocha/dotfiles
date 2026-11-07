--- Path to `<root_dir>/node_modules/.bin/<name>` if it is executable, else the bare `name`.
---@param root_dir string?
---@param name string
---@param accept? fun(path: string): boolean Extra check the local binary must pass.
---@return string
return function(root_dir, name, accept)
    if root_dir then
        local path = vim.fs.joinpath(root_dir, 'node_modules/.bin', name)
        if vim.fn.executable(path) == 1 and (not accept or accept(path)) then
            return path
        end
    end
    return name
end
