# tmux keeps the OSC 7 that fish sends to itself, so Ghostty never learns the
# directory and its new_window opens where tmux was started. Pass it through,
# and again when the pane gains focus so Ghostty follows the active pane.
if status is-interactive; and set -q TMUX
    function __tmux_report_pwd --on-variable PWD --on-event fish_focus_in
        printf '\ePtmux;\e\e]7;file://%s%s\e\e\\\\\e\\\\' $hostname (string escape --style=url -- $PWD)
    end
    __tmux_report_pwd
end
