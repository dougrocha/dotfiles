local M = {}

M.update_git_head = function()
    local cwd = vim.fn.getcwd()

    -- First check if we're in a git repository
    local git_dir_cmd = string.format('git -C %s rev-parse --git-dir 2>/dev/null', vim.fn.shellescape(cwd))
    vim.fn.system(git_dir_cmd)

    if vim.v.shell_error ~= 0 then
        vim.b._git_head = ''
        return
    end

    -- Use git symbolic-ref for better branch detection
    local branch_cmd = string.format('git -C %s symbolic-ref --short HEAD 2>/dev/null', vim.fn.shellescape(cwd))
    local branch = vim.trim(vim.fn.system(branch_cmd))

    if vim.v.shell_error == 0 and branch ~= '' then
        vim.b._git_head = branch
    else
        -- Fallback to describe for detached HEAD or tags
        local describe_cmd =
            string.format('git -C %s describe --exact-match --tags HEAD 2>/dev/null', vim.fn.shellescape(cwd))
        local tag = vim.trim(vim.fn.system(describe_cmd))

        if vim.v.shell_error == 0 and tag ~= '' then
            vim.b._git_head = tag
        else
            -- Final fallback to short commit hash
            local commit_cmd = string.format('git -C %s rev-parse --short HEAD 2>/dev/null', vim.fn.shellescape(cwd))
            local commit = vim.trim(vim.fn.system(commit_cmd))

            if vim.v.shell_error == 0 and commit ~= '' then
                vim.b._git_head = commit
            else
                vim.b._git_head = ''
            end
        end
    end
end

vim.api.nvim_create_autocmd({
    'BufEnter',
    'BufRead',
    'BufNewFile',
    'FocusGained',
    'DirChanged',
    'BufWritePost',
}, {
    group = vim.api.nvim_create_augroup('dougrocha/git', { clear = true }),
    callback = M.update_git_head,
})

return M
