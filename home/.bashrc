# Environment (DOTFILES_DIR, BUILD_DIR — written by linux-setup.sh)
[[ -f "$HOME/.config/env" ]] && source "$HOME/.config/env"

# XDG Base Directories
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# Editor
export EDITOR=nvim
export GIT_EDITOR=nvim
export VISUAL=nvim
export MANPAGER="nvim +Man!"

# Notes
export SECOND_BRAIN="$HOME/second-brain"

# My scripts
export PATH="$HOME/.local/bin:$PATH"

# Cargo/Rust environment
export PATH="$HOME/.cargo/bin:$PATH"
. "$HOME/.cargo/env"

# Turso
export PATH="$PATH:$HOME/.turso"

# Android SDK
if [[ "$(uname)" == "Linux" ]]; then
    export ANDROID_HOME=/opt/android-sdk
    export ANDROID_AVD_HOME="$HOME/.config/.android/avd"
elif [[ "$(uname)" == "Darwin" ]]; then
    export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
    export ANDROID_HOME="$HOME/Library/Android/sdk"
fi
if [[ -d "$ANDROID_HOME" ]]; then
    export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
    export PATH="$ANDROID_HOME/emulator:$PATH"
    export PATH="$ANDROID_HOME/platform-tools:$PATH"
fi

# mise (runtime version manager)
eval "$(mise activate bash)"
