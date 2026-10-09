# <App> verification map

This directory is the maintained source for verifying the user-facing behavior of <app>. Read this index before you drive, then use the matching feature file as the recipe.

## Baseline preconditions

- `<tool> doctor` prints `ok` on every line.
- `<tool> start <feature-id>` made the run's evidence directory.
- `<tool> reset` ran.
- <Seed data or environment the recipes expect.>

## Driving conventions

- <How to send each kind of input.>
- Use shortcuts (IPC, API) only to set up or reset state, never as the proof of a user path.
- Restore every setting you change.

## Proof and skip reporting

- Pair each user action with its result.
- Record the feature ID and the entry point with every result line.
- Report an unreachable path with the command you ran and the precondition that failed.
- Do not report an entry point as verified because another entry point worked.

## Feature entry contract

Each feature file starts with an H1 title and one paragraph about the user-visible behavior. Then it has exactly four H2 sections in this order:

1. `Sub-features` lists short IDs with one line each.
2. `How to get to it (user POV)` lists every user entry point.
3. `Driving it with <tool>` starts with `Preconditions:`. Each bullet pairs a user action with an exact command and the result you can observe.
4. `Gotchas` lists traps that waste or invalidate a run.

## Features

- [<Feature>](./feature.md) covers <entry points and states>.
