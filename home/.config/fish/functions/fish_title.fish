function fish_title
    set -l dir (string replace -r -- '^'(string escape --style=regex -- $HOME) '~' $PWD)
    set -l command $argv[1]
    set -q command[1]; or set command (status current-command)
    if test "$command" = fish
        echo -- $dir
    else
        echo -- (string sub -l 20 -- $command) · $dir
    end
end
