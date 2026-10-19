function fish_title
    # Ends with the full directory so terminal-cwd can read it back from the
    # window title. A running command goes in front: "nvim · ~/dev/dotfiles".
    set -l dir (string replace -r -- '^'(string escape --style=regex -- $HOME) '~' $PWD)
    set -l command $argv[1]
    set -q command[1]; or set command (status current-command)
    if test "$command" = fish
        echo -- $dir
    else
        echo -- (string sub -l 20 -- $command) · $dir
    end
end
