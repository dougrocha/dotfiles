function sync-obsidian
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

    set SOURCE_DIR "$SECOND_BRAIN/"
    set DEST_DIR "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/second-brain/"

    set GREEN (set_color green)
    set RED (set_color red)
    set NORMAL (set_color normal)

    echo "🔄 Starting Obsidian sync to iCloud..."

    mkdir -p "$DEST_DIR"

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
