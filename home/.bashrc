[[ -f "$HOME/.config/env" ]] && source "$HOME/.config/env"

export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

export EDITOR=nvim
export GIT_EDITOR=nvim
export VISUAL=nvim
export MANPAGER="nvim +Man!"

export SECOND_BRAIN="$HOME/second-brain"

export PATH="$HOME/.local/bin:$PATH"

export PATH="$HOME/.cargo/bin:$PATH"
. "$HOME/.cargo/env"

export PATH="$PATH:$HOME/.turso"

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

eval "$(mise activate bash)"
