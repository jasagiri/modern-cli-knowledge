# Specification: modern-cli-knowledge

Repository-level behaviour. Each row is one spec ID; tests carry `# SPEC: <ID>`. The per-task
statements (what each tool does on the fixture) are in `docs/spec/*.md`.

## Pages (ADR-MCLI-0002)

| ID | Statement |
|---|---|
| MCLI-PAGE-01 | Every details page has a `# ` title and the sections Intent, Classic and modern, Commands, Differences that change results, When to keep the classic command, Pitfalls, Sources, in that order. |
| MCLI-PAGE-02 | A page whose examples cannot be run here carries `Status: 未検証 (<reason>)` under its title and has only ```sh unverified commands; a verified page has no ```sh unverified block. |
| MCLI-PAGE-03 | Blocks pair as the rules of `src/shell_pages/pages.nim` in nim-shell-pages say: ```sh then ```text; ```sh classic or ```sh bad then ```sh then ```text; a ```text after nothing to run, or a malformed `# exit: N`, or a second `# exit:` line in one command, is an error naming its line. |
| MCLI-PAGE-04 | SKILL.md links every details page, and every page it links exists. |
| MCLI-PAGE-05 | The Sources section of each page lists catalog IDs that exist in catalog/sources.jsonl, or says "None in the catalog:" with a reason. |

## Examples (ADR-MCLI-0002)

| ID | Statement |
|---|---|
| MCLI-EX-01 | Every example command, run with `sh -c` in a fresh copy of fixtures/tree (each `_gitignore` renamed `.gitignore`, an empty `.git` directory at the root) under a fixed environment (`env -i`, `LC_ALL=C.UTF-8`, `TZ=UTC`, `NO_COLOR=1`, `TERM=dumb`, `PAGER=cat`, `HOME` inside the copy), prints exactly its ```text block on standard output. |
| MCLI-EX-02 | Every example command ends with the status of its `# exit: N` line, or 0 without one. |
| MCLI-EX-03 | The ```sh classic command of a rewrite pair prints the same ```text as the modern command, in its own fresh copy. |
| MCLI-EX-04 | A ```sh idempotent command run twice leaves the tree byte-identical to running it once. |
| MCLI-EX-05 | Running the examples leaves fixtures/tree unchanged. |

## Spec tables (ADR-MCLI-0002)

| ID | Statement |
|---|---|
| MCLI-SPEC-01 | A command may start with `# spec: CLI-<TOOL>-NN ...` lines, in any order with the `# exit: N` line; the example then names those IDs, and a malformed line is an error naming its line. |
| MCLI-SPEC-02 | Each details page has a table docs/spec/<page>.md with one row per claim (ID `CLI-<TOOL>-NN`, 箇所, 主張, 確かめ). TOOL is the upper-cased tool of the page title when the part after its colon is one word; on a page about several tools every row uses the TOOL of the table's first row. 箇所 names exactly one bullet, `D<n>` or `K<n>`, and the claim is not empty. A row marked `例` is named by a `# spec:` line of an example of the page; a row marked `本文のみ (<category>: <reason>)` is named by none, its category one of 助言 (advice on when to choose, not a result), 版 (the version, checked by MCLI-VER-01), 端末 (needs a terminal), 通信 (needs the network or a server), 機械 (depends on the machine: its OS, mounts, sizes, users, or tools it lacks), 時間 (depends on measured time or on history), 非決定 (the order changes between runs); no example names an ID missing from the table; IDs are unique across all tables. This is the G1 of the pages: its denominator is the rows marked `例`, and the text-only rows are the ones outside it, each with its reason. |
| MCLI-SPEC-03 | Every bullet of "Differences that change results" (D1, D2, …) and of "When to keep the classic command" (K1, K2, …) is pointed at by at least one row, and no row points past the bullets. |

## Tool versions (ADR-MCLI-0002)

| ID | Statement |
|---|---|
| MCLI-VER-01 | Each tool listed in docs/tool-versions.md as verified prints, for its version command, the line recorded there; a different version fails the test and names the tool. |

## Dataset (ADR-MCLI-0003)

| ID | Statement |
|---|---|
| MCLI-DATA-01 | Rebuilding dataset/ from the pages gives the committed bytes. |
| MCLI-DATA-02 | Every record comes from a verified example (`task`, `rewrite`, `pitfall`) or a page section (`explain`, `keep-classic`); no record comes from a ```sh unverified block. |
| MCLI-DATA-03 | chat.jsonl holds the same records as records.jsonl, one system/user/assistant triple each, in the same order. |
