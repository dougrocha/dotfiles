function sync-obsidian
    # Obsidian to iCloud Sync Script (macOS only)
    if test (uname) != "Darwin"
        echo "sync-obsidian: iCloud sync only works on macOS" >&2
        return 1
    end

    if test -z "$SECOND_BRAIN"
        echo "sync-obsidian: SECOND_BRAIN is not set" >&2
        return 1
    end

    if not test -d "$SECOND_BRAIN"
        echo "sync-obsidian: SECOND_BRAIN is not a directory: $SECOND_BRAIN" >&2
        return 1
    end

    # Set your paths here
    set SOURCE_DIR "$SECOND_BRAIN/"
    set DEST_DIR "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/second-brain/"

    # Colors for output
    set GREEN (set_color green)
    set RED (set_color red)
    set NORMAL (set_color normal)

    echo "🔄 Starting Obsidian sync to iCloud..."

    # Create destination if it doesn't exist
    mkdir -p "$DEST_DIR"

    # Rsync with options:
    # -a: archive mode (preserves permissions, timestamps, etc)
    # -v: verbose
    # --delete: remove files in dest that don't exist in source
    # --exclude: skip these patterns
    rsync -av --delete \
        --exclude='.obsidian/workspace*' \
        --exclude='*.swp' \
        --exclude='*.un~' \
        --exclude='.DS_Store' \
        --exclude='.git/' \
        "$SOURCE_DIR" "$DEST_DIR"
    set -l rc $status

    if test $rc -eq 0
        echo "$GREEN✅ Sync completed successfully!$NORMAL"
    else
        echo "$RED❌ Sync failed with error code $rc$NORMAL"
        return 1
    end
end
