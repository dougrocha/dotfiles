---
name: <name>
description: <What the skill covers, in one sentence>. Use this skill <when: before or after which action, for which files or tasks>. Use <other-skill> for <the related task it does not cover>.
# disable-model-invocation: true  # keep only for a skill that runs when the user types /<name>
---

# <Title>

<One or two sentences: what this is and the goal.>

<Where it is: "The config is in `<path>` in this repo. All paths in this skill are relative to <directory>.">

## Rules

- WARNING: <An action that breaks the user's session or data. Put it first.>
- <A rule that applies to every step.>

## 1. <First task>

1. <Step. One instruction per sentence.>
2. Run `<command>`. <What a correct result looks like.>
3. If <failure>, <recovery>. Then do step 2 again.

## 2. <Second task>

| <Task or value> | <Pattern or command> | <Example file> |
|---|---|---|
| <...> | <...> | `<path/to/real/file>` |

## 3. Known problems

| Problem | Cause and correction |
|---|---|
| <The symptom the agent sees> | <The cause. The correction.> |

## References

- Read [<topic>](references/<topic>.md) when <condition>.

## Checklist

Before you finish, make sure that:

- `<check script>` prints no problems.
- <A check that only judgment can do.>
