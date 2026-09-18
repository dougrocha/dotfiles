import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { CONFIG_DIR_NAME, isToolCallEventType } from "@earendil-works/pi-coding-agent";
import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";

/**
 * Recreates the per-project Bash/WebFetch allowlist habit from Claude Code's
 * `.claude/settings.local.json` (permissions.allow). Pi has no built-in
 * per-tool permission system by design (see docs/security.md - "No
 * permission popups": build your own confirmation flow). This extension
 * restores that workflow: commands matching a project-local allowlist run
 * silently; everything else prompts once per distinct command.
 *
 * Config file: <project>/.pi/allowlist.json
 * {
 *   "bash": ["gh api *", "git log *", "cargo check *", "curl *"]
 * }
 *
 * Patterns use simple glob syntax: "*" matches any run of characters.
 * Matching is against the full command string pi would execute.
 */

type AllowlistConfig = { bash?: string[] };

// Claude Code effectively didn't nag for mundane inspection commands. Since this
// extension gates bash broadly when a project allowlist exists, keep common
// read-only discovery commands frictionless while still prompting for commands
// that mutate the repo/system or hit external services.
const DEFAULT_SAFE_READONLY = [
  "pwd",
  "ls",
  "ls *",
  "find *",
  "rg *",
  "grep *",
  "git status*",
  "git diff*",
  "git show*",
  "git log*",
  "git branch*",
  "git rev-parse*",
  "git ls-files*",
  "mise *",
  "pacman -Q *",
];

function globToRegExp(glob: string): RegExp {
  const escaped = glob.replace(/[.+^${}()|[\]\\]/g, "\\$&").replace(/\*/g, ".*");
  return new RegExp(`^${escaped}$`);
}

function loadAllowlist(cwd: string): RegExp[] {
  const path = join(cwd, CONFIG_DIR_NAME, "allowlist.json");
  if (!existsSync(path)) return [];
  try {
    const config = JSON.parse(readFileSync(path, "utf8")) as AllowlistConfig;
    return [...DEFAULT_SAFE_READONLY, ...(config.bash ?? [])].map(globToRegExp);
  } catch {
    return DEFAULT_SAFE_READONLY.map(globToRegExp);
  }
}

export default function (pi: ExtensionAPI) {
  let patterns: RegExp[] = [];
  const approvedThisSession = new Set<string>();

  pi.on("session_start", (_event, ctx) => {
    patterns = loadAllowlist(ctx.cwd);
  });

  pi.on("tool_call", async (event, ctx) => {
    if (!isToolCallEventType("bash", event)) return;
    if (!ctx.isProjectTrusted()) return; // don't gate untrusted-project runs differently than pi already does
    if (patterns.length === 0) return; // no allowlist configured -> don't change behavior

    const command = event.input.command;
    if (patterns.some((re) => re.test(command))) return; // allowlisted, run silently
    if (approvedThisSession.has(command)) return; // already approved once this session

    if (!ctx.hasUI) {
      return { block: true, reason: "Not in project allowlist and no UI is available to confirm" };
    }

    const ok = await ctx.ui.confirm("Run command?", command);
    if (!ok) return { block: true, reason: "Not in project allowlist and declined by user" };
    approvedThisSession.add(command);
  });
}
