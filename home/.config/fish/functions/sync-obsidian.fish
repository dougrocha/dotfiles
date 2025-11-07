function sync-obsidian
    # Obsidian to iCloud Sync Script
    # Set your paths here
    set SOURCE_DIR ~/second-brain/
    set DEST_DIR ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/second-brain/

    # Colors for output
    set GREEN (set_color green)
    set RED (set_color red)
    set NORMAL (set_color normal)

    echo "🔄 Starting Obsidian sync to iCloud..."

    # Create destination if it doesn't exist
    mkdir -p $DEST_DIR

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
        $SOURCE_DIR $DEST_DIR

    if test $status -eq 0
        echo "$GREEN✅ Sync completed successfully!$NORMAL"
    else
        echo "$RED❌ Sync failed with error code $status$NORMAL"
        return 1
    end
end
