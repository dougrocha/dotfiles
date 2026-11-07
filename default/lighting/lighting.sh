# shellcheck shell=bash
# shellcheck disable=SC2034  # used by the scripts that source this file
# Paths and the lock shared by set-lighting and the scripts it calls.
# kraken-lcd.service runs as root, so the state lives under the home of the
# user who owns the dotfiles, not $HOME.

lighting_dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
lighting_home="$(getent passwd "$(stat -c %U "$lighting_dotfiles_dir")" | cut -d: -f6)" || lighting_home=""
if [[ -z $lighting_home ]]; then
    echo "Error: can't find the home of the dotfiles owner" >&2
    exit 1
fi

lighting_state_dir="$lighting_home/.local/state/lighting"
lighting_state_file="$lighting_state_dir/current"
lighting_lock_file="$lighting_state_dir/lock"
lighting_openrgb_bin="${BUILD_DIR:-$lighting_home/builds}/openrgb-src/openrgb"

# Holds the lock on fd 9 until the script exits. Callers of set-lighting skip
# it through LIGHTING_LOCKED. An existing lock opens read-only, so running as
# root never leaves a root-owned file the user can't open. Root with no lock
# file means set-lighting has never run, so there is nothing to race.
lighting_lock() {
    if [[ -n ${LIGHTING_LOCKED:-} ]]; then
        return 0
    fi
    if [[ -e $lighting_lock_file ]]; then
        exec 9<"$lighting_lock_file"
    elif ((EUID != 0)); then
        mkdir -p "$lighting_state_dir"
        exec 9>"$lighting_lock_file"
    else
        return 0
    fi
    flock 9
    export LIGHTING_LOCKED=1
}
