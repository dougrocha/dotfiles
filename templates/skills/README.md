# Skill templates

Templates and a checker for agent skills. Copy a template into `<repo>/.claude/skills/<name>/`, replace every `<placeholder>`, and run `check-skills`.

## Layout

| Path | Use it for |
|---|---|
| `skill/` | A rules or procedure skill: `SKILL.md` and an optional `references/` directory. |
| `skill/references/reference.md` | A reference doc. Keep the table of contents when the doc is longer than 100 lines. |
| `principle/` | A short engineering principle that other skills load: the rule, when it applies, and how to check it. |
| `verify/` | A verification skill that drives the real app: Launch, Doctor, Drive, Evidence, Cleanup. It has a feature map in `features/` and a helper CLI in `bin/`. |
| `check-skills` | The checker for the rules below. |

## Rules

`check-skills` checks the rules that a script can prove. It exits 1 when a rule fails.

```sh
templates/skills/check-skills [skill-dir-or-root ...]   # default: .claude/skills
```

- `SKILL.md` has frontmatter. `name` is the directory name. `description` says what the skill does and when to use it.
- `SKILL.md` is 200 lines or fewer. Move detail to `references/<topic>.md` and link it from `SKILL.md` with the condition to read it.
- A doc other than `SKILL.md` that is longer than 100 lines starts with a `## Contents` list.
- Each file in `references/` is linked or named from a doc in the skill.
- Each file in `features/` is listed in `features/README.md`.
- A helper script with a shebang is executable.
- Relative links resolve.

Keep `features/` as its own directory in a verify skill. It is the maintained feature map, not overflow from `SKILL.md`.

## Code before prose

Write a script when an instruction is one of these:

- A command that the agent must type exactly, for example a long pipeline or a list of flags.
- A check with a yes or no answer, for example "no hex colors" or "one instance runs".
- A list that the code already knows, for example IPC targets or routes. Read the list at run time.
- Setup or teardown with more than two steps.

Keep prose for judgment: design rules, the order of steps, and why a trap exists. When a script owns a fact, the skill names the script and does not repeat the fact.

## The 3Cs

Check each skill against these before you commit it.

**Clear**
- Write one instruction in each sentence. Use the imperative: "Run", "Use", "Do not".
- Name the exact file, command, or token. Do not write "the config" when there are two.
- Say where paths start: the repo root or another named directory.
- Put a warning before the step that it applies to.

**Concise**
- Keep each fact in one place. Link to it from other skills.
- Remove history and rationale that does not change what the agent does.
- Use a table for a mapping and a numbered list for a procedure.

**Correct**
- Each path, command, and name in the skill exists now. Run the commands one time before you commit.
- Each example points to a real file.
- Skills that cover the same tool agree on values such as wait times and rules.
- Read values that change (monitors, ports, colors, counts) at run time. Do not write them in the skill.
