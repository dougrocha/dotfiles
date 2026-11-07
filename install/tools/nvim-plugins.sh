#!/bin/bash
# Without force, vim.pack.update only opens a confirmation buffer.
# Headless `qa` then quits without applying updates or writing nvim-pack-lock.json.

set -euo pipefail

nvim --headless -c 'lua vim.pack.update(nil, { force = true })' -c 'qa'

# vim: ft=sh
