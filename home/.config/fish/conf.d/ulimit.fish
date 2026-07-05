# Raise max open files (macOS only)
# Default of 256 is too low: nvim file-watchers, swapfiles, sockets, and
# channels consume file descriptors and can hit EMFILE errors.
if test (uname) = "Darwin"
    ulimit -n 8192
end
