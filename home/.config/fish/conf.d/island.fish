# Announce long commands in the Quickshell island when they finish
set -g island_min_duration 15000
set -g island_ignore nvim vim lazygit tmux ssh man less bat claude yazi htop btop

function __island_command_done --on-event fish_postexec
    set -l code $status
    set -q HYPRLAND_INSTANCE_SIGNATURE; or return
    test "$CMD_DURATION" -ge $island_min_duration; or return
    set -l name (string split -f1 ' ' -- (string trim -- $argv[1]))
    contains -- $name $island_ignore; and return

    set -l seconds (math --scale=0 $CMD_DURATION / 1000)
    set -l took {$seconds}s
    test $seconds -ge 60; and set took (math --scale=0 $seconds / 60)m (math $seconds % 60)s

    if test $code -eq 0
        command qs ipc call island push command checkCircle "$name finished · $took" 4 >/dev/null 2>&1
    else
        command qs ipc call island push command warningCircle "$name failed · $took" 6 >/dev/null 2>&1
    end
end
