set -x GOPATH /usr/local/go
set -x PATH $PATH $GOPATH/bin

set -gx EDITOR nvim

set -gx PNPM_HOME "/home/dougr/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end