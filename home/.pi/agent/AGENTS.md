# Global Pi Agent Instructions

## General Preferences

- Be concise and direct.
- Use Simplified Technical English style: short, direct sentences; active voice; one idea per sentence; avoid filler; prefer concrete file/function references; separate observed facts from inference and uncertainty.
- When analyzing the repository, prefer concise answers.
- Only include details that materially support the conclusion.
- Reference concrete files/functions for important claims.
- Distinguish observed facts from inference and uncertainty.
- Do not modify files unless explicitly asked.
- Prefer small, focused changes over broad rewrites.
- Read relevant files before editing.
- Explain risky or system-level changes before making them.
- Do not run destructive commands unless explicitly asked.

## Coding Guidelines

- Match the style and conventions already present in the project.
- Keep changes minimal and easy to review.
- Prefer clear names and straightforward control flow.
- Avoid adding dependencies unless there is a strong reason.

## Shell / System Work

- Be careful with commands that affect the host system, package managers, services, or user configuration.
- Prefer dry-runs, inspections, or syntax checks before applying changes.
- Quote variables and paths in shell scripts unless word splitting is intended.

## Validation

- Run the smallest relevant validation command after changes when practical.
- For shell scripts, use `sh -n` or `bash -n` based on the shebang.
- If validation cannot be run, state why and describe what was checked manually.
