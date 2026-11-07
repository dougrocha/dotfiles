# macOS defaults to 256 open files, which nvim file watchers, swapfiles and sockets exhaust.
if test -e /System/Library/CoreServices/SystemVersion.plist
    ulimit -n 8192
end
