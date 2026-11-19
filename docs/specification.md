# Specification: modern-cli-knowledge

Repository-level behaviour. Each row is one spec ID; tests carry `# SPEC: <ID>`. The per-task
statements (what each tool does on the fixture) are in `docs/spec/*.md`.

## Pages (ADR-MCLI-0002)

| ID | Statement |
|---|---|
| MCLI-PAGE-01 | Every details page has a `# ` title and the sections Intent, Classic and modern, Commands, Differences that change results, When to keep the classic command, Pitfalls, Sources, in that order. |
| MCLI-PAGE-02 | A page whose examples cannot be run here carries `Status: 未検証 (<reason>)` under its title and has only ```sh unverified commands; a verified page has no ```sh unverified block. |
| MCLI-PAGE-03 | Blocks pair as the rules of `src/mcli/pages.nim` say: ```sh then ```text; ```sh classic or ```sh bad then ```sh then ```text; a ```text after nothing to run, or a malformed `# exit: N`, is an error naming its line. |
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
