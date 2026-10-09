---
name: verify-<app>
description: Drive <app> (<the surface: web UI, CLI, desktop shell>) the way a user does with <harness>, and capture <screenshots, transcripts, files> as proof. Use it to prove that a change to <features> works end to end, not only that it builds. Use <dev-skill> for <reload, log, and build steps>.
---

# Verify <app>

<One paragraph: what the user touches, and what this skill drives.>

The helper is `.claude/skills/verify-<app>/bin/<tool>`, relative to the repo root. Run `<tool> help` for every subcommand.

The feature recipes are in `features/`. Read `features/README.md` first.

## 1. Launch

<Command that starts the app, or "Nothing to launch: the user's instance runs already.">

- WARNING: <What never to start or kill, for example a second instance.>
- Ready means `<tool> doctor` prints `ok` on every line.
- Run `<tool> start <feature-id>` before you capture anything. It makes the evidence directory and prints its path.

## 2. Doctor

Run `<tool> doctor` before you drive, and again when a result looks wrong. It is read only. It checks:

- <Process up, and it is ours.>
- <The right build or checkout.>
- <The input and capture tools are installed.>

It prints the values that change (ports, monitors, sizes). Take them from that output, not from memory.

## 3. Drive

Use real input. A shortcut such as IPC or an API call is for setup and reset only. It does not prove the user path.

| User action | Command | Notes |
|---|---|---|
| <Press a shortcut> | `<tool> key <chord>` | |
| <Click> | `<tool> click <target>` | <Prefer stable handles: ARIA names, data attributes.> |

Run `<tool> reset` before each case.

## 4. Evidence

- Capture the action and the resulting state, not only the last screen.
- Check side effects as well as pixels: <files, URL, focus, stored state>.
- Read each image before you make a claim from it.
- Write each result with the expected value: `<feature-id>, expect <value>: <actual>`.
- Name the feature ID and the entry point. An entry point that you did not drive is not verified.

## 5. Cleanup

Run `<tool> cleanup` at the end and after each failed attempt. It stops only what this run started. It keeps the evidence in `<evidence dir>`.

Tell the user which state you changed and restored.

## 6. Gotchas

- **<Short trap name>.** <What happens. What to do.>
