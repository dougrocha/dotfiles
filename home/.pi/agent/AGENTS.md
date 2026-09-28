# Global Pi Agent Instructions

## Style

- Write in Simplified Technical English: short sentences, active voice, one idea per sentence, no filler.
- Include only details that support the conclusion.
- Reference concrete files and functions for important claims.
- Separate observed facts from inference and uncertainty.

## Changes

- Do not modify files unless explicitly asked.
- Read relevant files before editing.
- Match the style and conventions already present in the project.
- Make small, focused changes that are easy to review. Avoid broad rewrites.
- Prefer clear names and straightforward control flow.
- Avoid adding dependencies unless there is a strong reason.

## Shell / System Work

- Do not run destructive commands unless explicitly asked.
- Explain risky or system-level changes before making them. This includes package managers, services, and user configuration.
- Prefer dry-runs, inspections, or syntax checks before applying changes.
- Quote variables and paths in shell scripts unless word splitting is intended.

## Validation

- Run the smallest relevant validation command after changes when practical.
- For shell scripts, use `sh -n` or `bash -n` based on the shebang.
- If validation cannot be run, state why and describe what was checked manually.
