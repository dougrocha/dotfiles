import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { isToolCallEventType } from "@earendil-works/pi-coding-agent";

/**
 * Recreates the trust-boundary policy from Claude Code's Auto Mode config
 * (~/.claude/settings.json -> autoMode.environment) as a Pi extension, since
 * Pi has no built-in per-tool permission system ("no permission popups" by
 * design) - see docs/security.md. This confirms before destructive git/shell
 * operations instead of silently blocking them.
 *
 * Edit PROTECTED_BRANCHES / SENSITIVE_PATTERN / SENSITIVE_FILES below to match
 * your own trust boundary.
 */

const PROTECTED_BRANCHES = ["main", "master"];
// Matches "prod"/"production" as a whole word/segment (hyphen/underscore/dot-delimited).
const SENSITIVE_PATTERN = /(^|[-_./])prod(uction)?([-_./]|$)/i;
const SENSITIVE_FILES = [/(^|\/)\.env(\..*)?$/, /(^|\/)credentials(\.\w+)?$/i, /\.pem$/i, /\.key$/i];

function isDangerousBash(command: string): string | null {
  if (/\brm\s+-[a-z]*r[a-z]*f\b|\brm\s+-[a-z]*f[a-z]*r\b/i.test(command)) {
    return "rm -rf (recursive force delete)";
  }
  if (/\bgit\s+push\s+.*--force\b|\bgit\s+push\s+.*-f\b/.test(command)) {
    return "force push";
  }
  if (PROTECTED_BRANCHES.some((b) => new RegExp(`\\bgit\\s+push\\b.*\\b${b}\\b`).test(command))) {
    return "push to a protected branch";
  }
  if (/\bgit\s+reset\s+--hard\b|\bgit\s+clean\s+-[a-z]*f/.test(command)) {
    return "discards uncommitted work";
  }
  if (SENSITIVE_PATTERN.test(command)) {
    return "targets a namespace/host tagged prod/production";
  }
  return null;
}

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    if (isToolCallEventType("bash", event)) {
      const reason = isDangerousBash(event.input.command);
      if (reason) {
        if (!ctx.hasUI) return { block: true, reason: `Blocked by guardrail: ${reason}` };
        const ok = await ctx.ui.confirm(
          "Guardrail",
          `This command looks like: ${reason}.\n\n${event.input.command}\n\nRun it anyway?`,
        );
        if (!ok) return { block: true, reason: `Blocked by guardrail: ${reason}` };
      }
    }

    if (isToolCallEventType("write", event) || isToolCallEventType("edit", event)) {
      const path = (event.input as { path?: string }).path ?? "";
      if (SENSITIVE_FILES.some((re) => re.test(path))) {
        if (!ctx.hasUI) return { block: true, reason: "Blocked by guardrail: sensitive file path" };
        const ok = await ctx.ui.confirm(
          "Guardrail",
          `About to write a sensitive-looking file: ${path}\n\nProceed?`,
        );
        if (!ok) return { block: true, reason: "Blocked by guardrail: sensitive file path" };
      }
    }
  });
}
