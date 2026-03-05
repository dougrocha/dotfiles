# Android SDK Setup
if test (uname) = "Darwin"
    # macOS
    set -gx JAVA_HOME /Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
    set -gx ANDROID_HOME $HOME/Library/Android/sdk
else if test (uname) = "Linux"
    set -gx ANDROID_HOME /opt/android-sdk
    set -gx ANDROID_AVD_HOME $HOME/.config/.android/avd
end

if test -d "$ANDROID_HOME"
    fish_add_path -m "$ANDROID_HOME/cmdline-tools/latest/bin"
    fish_add_path "$ANDROID_HOME/emulator"
    fish_add_path "$ANDROID_HOME/platform-tools"
end
