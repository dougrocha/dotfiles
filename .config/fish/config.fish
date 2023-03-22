set -x LANG en_US.UTF-8

if status is-interactive
    # Commands to run in interactive sessions can go here
end

if status is-login
    # Commands to run in login shells can go here
    fish_add_path /opt/homebrew/bin
end

set PATH $HOME/.cargo/bin $PATH

direnv hook fish | source

starship init fish | source
