/**
 * Insert mode handler.
 * Passes all keys through to the base editor except Escape/Ctrl+[.
 * Tracks inserted text for dot-repeat.
 */

import type { VimState } from "../state.js";
import { matchesKey } from "@earendil-works/pi-tui";
import {
    isCurrentlyRecording,
    isRecordingInsertMode,
    recordInsertText,
    recordInsertBackspace,
    finalizeRecording,
} from "../repeat.js";

export interface InsertModeContext {
    state: VimState;
    getCursor: () => { line: number; col: number };
    superHandleInput: (data: string) => void;
}

/**
 * Handle input in insert mode.
 * Returns true if the key was handled, false if it should be passed to super.
 */
export function handleInsertMode(
    data: string,
    ctx: InsertModeContext,
): boolean {
    // Escape, Ctrl+[ or Ctrl+C → switch to normal mode (Ctrl+C skips pi's clear behavior).
    // matchesKey also covers the Kitty keyboard protocol encoding of ctrl+c.
    if (
        matchesKey(data, "escape") ||
        data === "\x1b" ||
        matchesKey(data, "ctrl+c")
    ) {
        ctx.state.mode = "normal";
        // Move cursor left one position (vim behavior: cursor moves back on Escape)
        // but only if not already at column 0 (to prevent moving up a line)
        if (ctx.getCursor().col > 0) {
            ctx.superHandleInput("\x1b[D");
        }
        // Finalize dot-repeat recording when leaving insert mode
        if (isCurrentlyRecording()) {
            finalizeRecording();
        }
        return true;
    }

    // Track inserted text for dot-repeat
    if (isCurrentlyRecording() && isRecordingInsertMode()) {
        if (data === "\x7f") {
            // Backspace
            recordInsertBackspace();
        } else if (data.length === 1 && data.charCodeAt(0) >= 32) {
            // Printable character
            recordInsertText(data);
        } else if (data === "\n" || data === "\r") {
            // Newline
            recordInsertText("\n");
        }
    }

    // Everything else passes through to base editor
    ctx.superHandleInput(data);
    return true;
}
