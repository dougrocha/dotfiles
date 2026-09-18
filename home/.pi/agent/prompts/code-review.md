---
description: Review working-tree changes for correctness bugs and simplification/efficiency issues
argument-hint: "[low|medium|high]"
---
Review the pending changes in this repo. Use `git diff` and `git diff --cached` together; if both are empty, review the most recent commit with `git show HEAD`.

Effort level: ${1:-medium}
- low/medium: report only findings you're confident are real bugs or clear cleanups.
- high: broaden coverage; lower-confidence findings are okay if clearly labeled as uncertain.

Focus on, in priority order:
1. **Correctness bugs** — concrete inputs or state that produce a wrong result, a crash, or data loss.
2. **Reuse/simplification** — duplicated logic, unneeded abstraction, dead code, premature generalization.
3. **Efficiency** — avoidable O(n^2) work, redundant I/O/allocations, blocking calls that should be async.

Do not comment on formatting/style unless it hides a bug. Skip test-coverage nagging unless a change clearly removes a safety net.

For each finding give: `file:line`, a one-sentence statement of the defect, and the concrete failure scenario (what input/state triggers it). Rank most-severe first.

If nothing survives review, say so plainly — do not invent minor nits to pad the response.
