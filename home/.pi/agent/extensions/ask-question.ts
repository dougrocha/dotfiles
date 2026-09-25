import { spawn } from "node:child_process";
import { mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { DynamicBorder, type ExtensionAPI, keyText, SettingsManager } from "@earendil-works/pi-coding-agent";
import { Input, Key, type KeyId, matchesKey, Text, truncateToWidth, visibleWidth, wrapTextWithAnsi } from "@earendil-works/pi-tui";
import { Type } from "typebox";

/**
 * Mirrors Claude Code's AskUserQuestion tool: 1-4 questions, each with a short
 * header chip, 2-4 options (label + description, optional preview) and an
 * automatic "Type something." row for free-form answers. Multiple questions
 * get a tab bar plus a final "Submit" review tab. j/k/h/l navigate wherever
 * typing isn't expected, and `n` attaches an inline note to the question.
 */

const MAX_QUESTIONS = 4;
const MIN_OPTIONS = 2;
const MAX_OPTIONS = 4;
const MAX_HEADER = 12;
const MAX_PREVIEW_LINES = 24;
const SIDE_BY_SIDE_MIN_WIDTH = 80;
const OTHER_PLACEHOLDER = "Type something.";

interface QuestionOption {
  label: string;
  description: string;
  preview?: string;
}

interface Question {
  question: string;
  header: string;
  options: QuestionOption[];
  multiSelect: boolean;
}

interface AskQuestionDetails {
  questions: Question[];
  // Keyed by question text, like Claude Code's `answers`.
  answers: Record<string, string>;
  // Question text -> note the user attached to that question.
  notes: Record<string, string>;
  cancelled: boolean;
}

interface QuestionState {
  cursor: number;
  // Single-select: chosen option index, or "other" for the typed answer.
  choice?: number | "other";
  // Multi-select: indices of checked options.
  checked: Set<number>;
  other: Input;
  note: string;
}

// Rows under a question: its options, the "Type something." row, and (multi-select only) Next/Submit.
type RowKind = "option" | "other" | "next";

function rowKind(q: Question, row: number): RowKind {
  if (row < q.options.length) return "option";
  return row === q.options.length ? "other" : "next";
}

function rowCount(q: Question): number {
  return q.options.length + (q.multiSelect ? 2 : 1);
}

const OptionSchema = Type.Object({
  label: Type.String({
    description: "The display text for this option (1-5 words). Should be concise and clearly describe the choice.",
  }),
  description: Type.String({
    description: "Explanation of what this option means or what will happen if chosen, including trade-offs.",
  }),
  preview: Type.Optional(
    Type.String({
      description:
        "Optional preview content shown in a monospace box when this option is focused. Use for ASCII mockups, code snippets, or config examples the user needs to compare visually. Single-select only.",
    }),
  ),
});

const QuestionSchema = Type.Object({
  question: Type.String({
    description: "The complete question to ask the user. Should be clear, specific, and end with a question mark.",
  }),
  header: Type.String({
    description: `Very short label displayed as a chip/tag (max ${MAX_HEADER} chars). Examples: "Auth method", "Library", "Approach".`,
  }),
  options: Type.Array(OptionSchema, {
    minItems: MIN_OPTIONS,
    maxItems: MAX_OPTIONS,
    description: `The available choices (${MIN_OPTIONS}-${MAX_OPTIONS}). Each should be distinct and mutually exclusive unless multiSelect is true. Do not add an "Other" option; one is provided automatically.`,
  }),
  multiSelect: Type.Boolean({
    description: "Set to true to allow the user to select multiple options instead of just one.",
  }),
});

const AskQuestionParams = Type.Object({
  questions: Type.Array(QuestionSchema, {
    minItems: 1,
    maxItems: MAX_QUESTIONS,
    description: `Questions to ask the user (1-${MAX_QUESTIONS}).`,
  }),
});

// Counts are enforced by the schema (pi validates arguments before execute); these checks are not.
function validate(questions: Question[]): string | undefined {
  const texts = new Set<string>();
  for (const q of questions) {
    if (!q.question.trim()) return "every question needs non-empty text.";
    if (texts.has(q.question)) return `duplicate question '${q.question}'; question texts must be unique.`;
    texts.add(q.question);
    const labels = new Set(q.options.map((o) => o.label));
    if (labels.size !== q.options.length) return `'${q.header}' has duplicate option labels.`;
  }
  return undefined;
}

function answerFor(q: Question, s: QuestionState): string | undefined {
  const otherText = s.other.getValue().trim();
  if (!q.multiSelect) {
    if (s.choice === undefined) return undefined;
    if (s.choice === "other") return otherText || undefined;
    return q.options[s.choice].label;
  }
  const picked = [...s.checked].sort((a, b) => a - b).map((i) => q.options[i].label);
  if (otherText) picked.push(otherText);
  return picked.length > 0 ? picked.join(", ") : undefined;
}

// Opens `command` (pi's externalEditor setting) on a temp file with the terminal handed over.
// Returns the edited text, or undefined if the editor failed or exited non-zero.
async function editExternally(command: string, content: string): Promise<string | undefined> {
  const dir = await mkdtemp(join(tmpdir(), "pi-ask-question-"));
  const file = join(dir, "answer.md");
  try {
    await writeFile(file, content, "utf-8");
    const [editor, ...args] = command.split(" ");
    const code = await new Promise<number | null>((resolve) => {
      const child = spawn(editor, [...args, file], { stdio: "inherit" });
      child.on("error", () => resolve(null));
      child.on("close", resolve);
    });
    return code === 0 ? await readFile(file, "utf-8") : undefined;
  } finally {
    await rm(dir, { recursive: true, force: true });
  }
}

function textResult(text: string, details: AskQuestionDetails) {
  return { content: [{ type: "text" as const, text }], details };
}

function previewBox(preview: string | undefined, width: number, border: (s: string) => string): string[] {
  const inner = Math.max(1, width - 4);
  const content = preview === undefined ? ["(no preview)"] : preview.replace(/\s+$/, "").split("\n");
  const shown = content.slice(0, MAX_PREVIEW_LINES);
  if (content.length > shown.length) shown.push(`… ${content.length - shown.length} more lines`);
  return [
    border(`┌${"─".repeat(Math.max(0, width - 2))}┐`),
    ...shown.map((line) => `${border("│")} ${truncateToWidth(line, inner, "…", true)} ${border("│")}`),
    border(`└${"─".repeat(Math.max(0, width - 2))}┘`),
  ];
}

export default function askQuestion(pi: ExtensionAPI) {
  pi.registerTool({
    name: "ask_question",
    label: "Ask Question",
    description:
      "Asks the user multiple-choice questions to gather information, clarify ambiguity, understand preferences, or offer choices. Use this only when blocked on a decision that is genuinely the user's to make. Users can always pick \"Other\" to type a custom answer, so never add one yourself. If you recommend an option, make it the first one and add \"(Recommended)\" to its label. Use `preview` on options to show ASCII mockups, code snippets, or config examples side by side.",
    promptSnippet:
      "Use ask_question when you need the user to make a decision you cannot resolve from the request, the code, or sensible defaults. Prefer it over a numbered list of questions in chat.",
    promptGuidelines: [
      `Ask 1-${MAX_QUESTIONS} questions per call, each with ${MIN_OPTIONS}-${MAX_OPTIONS} options and a header of at most ${MAX_HEADER} characters.`,
      "Set multiSelect: true only when the choices are not mutually exclusive.",
      "Do not use ask_question to confirm a plan or 'should I proceed?'; just act on sensible defaults and mention them.",
    ],
    parameters: AskQuestionParams,
    executionMode: "sequential",

    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      const questions: Question[] = params.questions.map((q) => ({
        question: q.question,
        header: truncateToWidth(q.header.trim() || q.question, MAX_HEADER, "…"),
        options: q.options,
        multiSelect: q.multiSelect,
      }));
      const empty: AskQuestionDetails = { questions, answers: {}, notes: {}, cancelled: true };

      if (ctx.mode !== "tui") {
        return textResult("Error: ask_question needs the interactive TUI.", empty);
      }
      const invalid = validate(questions);
      if (invalid) {
        return textResult(`Error: ${invalid}`, empty);
      }

      const result = await ctx.ui.custom<AskQuestionDetails>((tui, theme, kb, done) => {
        const submitTab = questions.length;
        const editorKey = keyText("app.editor.external");
        let tab = 0;
        let submitCursor = 0;
        // Notes capture every key while open, so one draft input is shared by all questions.
        let editingNote = false;
        let cachedLines: string[] | undefined;

        const makeInput = (placeholder: string) =>
          new Input({ prompt: "", placeholder, placeholderStyle: (t) => theme.fg("dim", t) });
        const noteDraft = makeInput("Add a note…");
        const states: QuestionState[] = questions.map(() => ({
          cursor: 0,
          checked: new Set<number>(),
          other: makeInput(OTHER_PLACEHOLDER),
          note: "",
        }));

        // A note can be sent without picking an option, so it needs the review tab to submit from.
        function hasSubmitTab(): boolean {
          return questions.length > 1 || states.some((s) => s.note !== "");
        }

        function lastTab(): number {
          return hasSubmitTab() ? submitTab : questions.length - 1;
        }

        type Focus = "submit" | "note" | "other" | "list";
        function focus(): Focus {
          if (tab === submitTab) return "submit";
          if (editingNote) return "note";
          const s = states[tab];
          return rowKind(questions[tab], s.cursor) === "other" ? "other" : "list";
        }

        function refresh() {
          cachedLines = undefined;
          tui.requestRender();
        }

        function finish(cancelled: boolean) {
          if (cancelled) {
            done(empty);
            return;
          }
          const answers: Record<string, string> = {};
          const notes: Record<string, string> = {};
          questions.forEach((q, i) => {
            const answer = answerFor(q, states[i]);
            if (answer !== undefined) answers[q.question] = answer;
            if (states[i].note) notes[q.question] = states[i].note;
          });
          done({ questions, answers, notes, cancelled: false });
        }

        function switchTab(delta: number) {
          tab = Math.max(0, Math.min(lastTab(), tab + delta));
          refresh();
        }

        // The Submit tab sits right after the last question, so stepping forward reaches it.
        function advance() {
          if (tab < lastTab()) switchTab(1);
          else finish(false);
        }

        function moveCursor(delta: number) {
          const s = states[tab];
          s.cursor = Math.max(0, Math.min(rowCount(questions[tab]) - 1, s.cursor + delta));
          refresh();
        }

        // Edit a single-line field straight in pi's external editor (nvim), flattening newlines.
        async function editInEditor(input: Input, onSave?: () => void) {
          tui.stop();
          try {
            const command = SettingsManager.create(ctx.cwd).getExternalEditorCommand();
            const next = await editExternally(command, input.getValue());
            if (next !== undefined) {
              input.setValue(next.replace(/\s+/g, " ").trim());
              onSave?.();
            }
          } finally {
            tui.start();
            cachedLines = undefined;
            tui.requestRender(true);
          }
        }

        function saveNote() {
          states[tab].note = noteDraft.getValue().trim();
          editingNote = false;
        }

        // Enter on a row: toggle an option (multi-select), pick it (single-select), or leave via Next.
        function activate() {
          const q = questions[tab];
          const s = states[tab];
          if (rowKind(q, s.cursor) === "option" && q.multiSelect) {
            if (s.checked.has(s.cursor)) s.checked.delete(s.cursor);
            else s.checked.add(s.cursor);
            refresh();
            return;
          }
          if (!q.multiSelect) s.choice = s.cursor;
          advance();
        }

        function handleSubmitInput(data: string) {
          if (matchesKey(data, Key.escape)) finish(true);
          else if (matchesKey(data, Key.up) || matchesKey(data, Key.down) || matchesKey(data, "j") || matchesKey(data, "k")) {
            submitCursor = 1 - submitCursor;
            refresh();
          } else if (matchesKey(data, Key.left) || matchesKey(data, Key.shift("tab")) || matchesKey(data, "h")) switchTab(-1);
          else if (matchesKey(data, "1")) finish(false);
          else if (matchesKey(data, "2")) finish(true);
          else if (matchesKey(data, Key.enter)) finish(submitCursor === 1);
        }

        function handleNoteInput(data: string) {
          if (kb.matches(data, "app.editor.external")) {
            void editInEditor(noteDraft, saveNote);
            return;
          }
          if (matchesKey(data, Key.enter)) saveNote();
          else if (matchesKey(data, Key.escape)) editingNote = false;
          else noteDraft.handleInput(data);
          refresh();
        }

        function handleOtherInput(data: string) {
          const q = questions[tab];
          const s = states[tab];
          const text = s.other.getValue();
          if (matchesKey(data, Key.tab)) switchTab(1);
          else if (matchesKey(data, Key.shift("tab"))) switchTab(-1);
          else if (matchesKey(data, Key.up)) moveCursor(-1);
          else if (matchesKey(data, Key.down)) moveCursor(1);
          // Left/right edit the text once there is some; until then they switch questions.
          else if (!text && matchesKey(data, Key.left)) switchTab(-1);
          else if (!text && matchesKey(data, Key.right)) switchTab(1);
          // Esc only leaves the field (keeping its text) instead of cancelling everything.
          else if (matchesKey(data, Key.escape)) moveCursor(-1);
          else if (kb.matches(data, "app.editor.external")) void editInEditor(s.other);
          else if (matchesKey(data, Key.enter)) {
            // Multi-select can move on without custom text; single-select needs it to count as a choice.
            if (q.multiSelect) advance();
            else if (text.trim()) {
              s.choice = "other";
              advance();
            }
          } else {
            s.other.handleInput(data);
            refresh();
          }
        }

        function handleListInput(data: string) {
          const q = questions[tab];
          const s = states[tab];
          const digit = [1, 2, 3, 4, 5, 6, 7, 8, 9].find((n) => matchesKey(data, String(n) as KeyId));
          if (matchesKey(data, Key.escape)) finish(true);
          else if (matchesKey(data, Key.tab) || matchesKey(data, Key.right) || matchesKey(data, "l")) switchTab(1);
          else if (matchesKey(data, Key.shift("tab")) || matchesKey(data, Key.left) || matchesKey(data, "h")) switchTab(-1);
          else if (matchesKey(data, Key.up) || matchesKey(data, "k")) moveCursor(-1);
          else if (matchesKey(data, Key.down) || matchesKey(data, "j")) moveCursor(1);
          else if (matchesKey(data, "n")) {
            editingNote = true;
            noteDraft.setValue(s.note);
            refresh();
          } else if (digit !== undefined && rowKind(q, digit - 1) !== "next") {
            // Number keys jump to a row and activate it (the "other" row just gets focus).
            s.cursor = digit - 1;
            if (rowKind(q, s.cursor) === "other") refresh();
            else activate();
          } else if (matchesKey(data, Key.enter)) activate();
          else if (matchesKey(data, Key.space) && q.multiSelect && rowKind(q, s.cursor) === "option") activate();
        }

        function handleInput(data: string) {
          const handlers: Record<Focus, (data: string) => void> = {
            submit: handleSubmitInput,
            note: handleNoteInput,
            other: handleOtherInput,
            list: handleListInput,
          };
          handlers[focus()](data);
        }

        function render(width: number): string[] {
          if (cachedLines) return cachedLines;

          const lines: string[] = [];
          const w = Math.max(1, width);
          const check = theme.fg("success", "✔");
          const pointer = (active: boolean) => (active ? theme.fg("accent", "❯ ") : "  ");
          const rowColor = (active: boolean) => (active ? "accent" : "text");
          const border = new DynamicBorder((t) => theme.fg("accent", t));

          function wrapInto(out: string[], prefix: string, text: string, lineWidth = w) {
            const prefixWidth = visibleWidth(prefix);
            if (prefixWidth >= lineWidth) {
              out.push(...wrapTextWithAnsi(prefix + text, lineWidth));
              return;
            }
            const wrapped = wrapTextWithAnsi(text, lineWidth - prefixWidth);
            const indent = " ".repeat(prefixWidth);
            wrapped.forEach((line, i) => out.push(`${i === 0 ? prefix : indent}${line}`));
          }
          const para = (text: string) => wrapInto(lines, " ", text);

          function renderTabBar() {
            if (!hasSubmitTab()) return;
            const chip = (label: string, active: boolean) => (active ? theme.inverse(label) : theme.fg("muted", label));
            const chips = questions.map((q, i) =>
              chip(` ${answerFor(q, states[i]) !== undefined ? check : "□"} ${q.header} `, i === tab),
            );
            chips.push(chip(" ✔ Submit ", tab === submitTab));
            lines.push(truncateToWidth(`${theme.fg("dim", "←")} ${chips.join(" ")} ${theme.fg("dim", "→")}`, w, "…"));
            lines.push("");
          }

          function renderOptions(q: Question, s: QuestionState, colWidth: number): string[] {
            const out: string[] = [];
            const numbered = (row: number) => {
              const active = row === s.cursor;
              return `${pointer(active)}${theme.fg(rowColor(active), `${row + 1}. `)}`;
            };
            const box = (checked: boolean) => (q.multiSelect ? `[${checked ? check : " "}] ` : "");

            q.options.forEach((opt, i) => {
              const chosen = s.choice === i ? ` ${check}` : "";
              const label = theme.fg(rowColor(i === s.cursor), opt.label);
              wrapInto(out, `${numbered(i)}${box(s.checked.has(i))}`, `${label}${chosen}`, colWidth);
              if (opt.description) wrapInto(out, "     ", theme.fg("muted", opt.description), colWidth);
            });

            const otherRow = q.options.length;
            const otherText = s.other.getValue().trim();
            const otherPrefix = `${numbered(otherRow)}${box(otherText !== "")}`;
            s.other.focused = s.cursor === otherRow && !editingNote;
            if (s.cursor === otherRow) {
              out.push(`${otherPrefix}${s.other.render(Math.max(1, colWidth - visibleWidth(otherPrefix)))[0]}`);
            } else if (otherText) {
              const chosen = s.choice === "other" ? ` ${check}` : "";
              wrapInto(out, otherPrefix, `${theme.fg("text", otherText)}${chosen}`, colWidth);
            } else {
              wrapInto(out, otherPrefix, theme.fg("dim", OTHER_PLACEHOLDER), colWidth);
            }

            if (q.multiSelect) {
              const active = rowKind(q, s.cursor) === "next";
              out.push("", `${pointer(active)}${theme.fg(rowColor(active), theme.bold(tab === lastTab() ? "Submit" : "Next"))}`);
            }
            return out;
          }

          function renderQuestion() {
            const q = questions[tab];
            const s = states[tab];
            para(theme.bold(theme.fg("text", q.question)));
            lines.push("");

            const hasPreview = q.options.some((o) => o.preview !== undefined);
            const focusedPreview = q.options[s.cursor]?.preview;
            const previewBorder = (t: string) => theme.fg("muted", t);
            if (hasPreview && w >= SIDE_BY_SIDE_MIN_WIDTH) {
              const leftWidth = Math.floor(w * 0.42);
              const left = renderOptions(q, s, leftWidth);
              const right = previewBox(focusedPreview, w - leftWidth - 2, previewBorder);
              for (let i = 0; i < Math.max(left.length, right.length); i++) {
                lines.push(`${truncateToWidth(left[i] ?? "", leftWidth, "", true)}  ${right[i] ?? ""}`);
              }
            } else {
              lines.push(...renderOptions(q, s, w));
              if (hasPreview) lines.push("", ...previewBox(focusedPreview, w, previewBorder));
            }

            const notePrefix = ` ${theme.fg("dim", "note:")} `;
            noteDraft.focused = editingNote;
            if (editingNote) {
              lines.push("", `${notePrefix}${noteDraft.render(Math.max(1, w - visibleWidth(notePrefix)))[0]}`);
            } else if (s.note) {
              lines.push("");
              wrapInto(lines, notePrefix, theme.italic(theme.fg("text", s.note)));
            }

            const switchHint = hasSubmitTab()
              ? `Tab/h/l to switch ${questions.length > 1 ? "questions" : "to Submit"}`
              : undefined;
            const help: Record<Exclude<Focus, "submit">, (string | undefined)[]> = {
              note: ["Enter to save note", "empty to remove", `${editorKey} to open editor`, "Esc to discard"],
              other: ["Enter to confirm", "↑/↓ to navigate", `${editorKey} to open editor`, "Esc to leave field"],
              list: [
                q.multiSelect ? "Space/Enter to toggle" : "Enter to select",
                "↑/↓ or j/k to navigate",
                switchHint,
                `n to ${s.note ? "edit" : "add"} note`,
                "Esc to cancel",
              ],
            };
            lines.push("");
            para(theme.fg("dim", help[focus() as Exclude<Focus, "submit">].filter(Boolean).join(" · ")));
          }

          function renderSubmit() {
            para(theme.bold(theme.fg("text", "Review your answers")));
            lines.push("");
            let missing = false;
            questions.forEach((q, i) => {
              const answer = answerFor(q, states[i]);
              if (answer === undefined) missing = true;
              wrapInto(lines, ` ${theme.fg("muted", "●")} `, theme.fg("text", q.question));
              wrapInto(lines, `   ${theme.fg("dim", "→")} `, answer === undefined ? theme.fg("warning", "(no answer)") : theme.fg("accent", answer));
              if (states[i].note) wrapInto(lines, `   ${theme.fg("dim", "note:")} `, theme.fg("muted", states[i].note));
            });
            lines.push("");
            if (missing) para(theme.fg("warning", "⚠ You have not answered all questions"));
            para(theme.fg("text", "Ready to submit your answers?"));
            ["Submit answers", "Cancel"].forEach((label, i) => {
              const active = i === submitCursor;
              wrapInto(lines, pointer(active), theme.fg(rowColor(active), `${i + 1}. ${label}`));
            });
            lines.push("");
            para(theme.fg("dim", "Enter to confirm · ↑/↓ or j/k to navigate · Shift+Tab/h to go back · Esc to cancel"));
          }

          lines.push(...border.render(w));
          renderTabBar();
          if (tab === submitTab) renderSubmit();
          else renderQuestion();
          lines.push(...border.render(w));

          cachedLines = lines;
          return lines;
        }

        return {
          render,
          invalidate: () => {
            cachedLines = undefined;
          },
          handleInput,
        };
      });

      if (result.cancelled) {
        return textResult("User declined to answer questions.", result);
      }

      const pairs = questions.flatMap((q) => {
        const answer = result.answers[q.question];
        const note = result.notes[q.question];
        if (answer === undefined && !note) return [];
        const noteText = note ? ` notes: ${note}` : "";
        const preview = q.multiSelect ? undefined : q.options.find((o) => o.label === answer)?.preview;
        const previewText = preview ? ` selected preview:\n${preview}` : "";
        return [`"${q.question}"=${answer === undefined ? "(no option selected)" : `"${answer}"`}${previewText}${noteText}`];
      });
      if (pairs.length === 0) {
        return textResult("User submitted without answering any questions.", result);
      }
      return textResult(
        `User has answered your questions: ${pairs.join(", ")}. You can now continue with the user's answers in mind.`,
        result,
      );
    },

    renderCall(args, theme) {
      const questions = Array.isArray(args.questions) ? args.questions : [];
      const headers = questions.map((q) => q?.header).filter(Boolean).join(", ");
      return new Text(
        theme.fg("toolTitle", theme.bold("ask_question ")) +
          theme.fg("muted", headers || `${questions.length} question${questions.length === 1 ? "" : "s"}`),
        0,
        0,
      );
    },

    renderResult(result, _options, theme) {
      const details = result.details as AskQuestionDetails | undefined;
      // Sessions from the previous version of this tool stored a different shape (answers as an array, no notes).
      if (!details || Array.isArray(details.answers) || !details.notes) {
        const first = result.content[0];
        return new Text(first?.type === "text" ? first.text : "", 0, 0);
      }
      if (details.cancelled) {
        return new Text(theme.fg("warning", "User declined to answer questions"), 0, 0);
      }
      return new Text(
        details.questions
          .map((q) => {
            const answer = details.answers[q.question];
            const note = details.notes[q.question];
            const line = answer === undefined
              ? `${theme.fg("dim", "· ")}${theme.fg("muted", q.header)}: ${theme.fg("dim", "(no answer)")}`
              : `${theme.fg("success", "✔ ")}${theme.fg("accent", q.header)}: ${answer}`;
            return note ? `${line}\n    ${theme.fg("dim", "note:")} ${theme.fg("muted", note)}` : line;
          })
          .join("\n"),
        0,
        0,
      );
    },
  });
}
