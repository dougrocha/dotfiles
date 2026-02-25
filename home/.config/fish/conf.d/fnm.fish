# Node version manager (fnm) configuration
if test (uname) = "Darwin"
    set FNM_PATH "/opt/homebrew/opt/fnm/bin"
else if test (uname) = "Linux"
    set FNM_PATH "$HOME/.local/share/fnm"
end

if test -d "$FNM_PATH"
    fnm env --use-on-cd --shell fish | source
end
