# modern-cli-knowledge

Modern Unix command-line tools (rg, fd, sd, bat, eza, dust, jq, yq, xh, delta, hyperfine, fzf) as an
agent skill and a training dataset for small models. Each task page says which classic command
the tool replaces, how the results differ (ignored and hidden files, regex dialect, order, in-place
editing, exit status), and when the classic POSIX command is still the right one. Every example
is run against a fixed file tree and its output compared byte for byte.

| path | what |
|---|---|
| `skills/modern-cli/SKILL.md`, `details/` | the agent skill (Agent Skills format), one page per task |
| `fixtures/tree/` | the file tree every example runs in (`_gitignore` becomes `.gitignore` in the copy) |
| `docs/tool-versions.md` | the tool versions the examples were checked with |
| `catalog/` | the sources: the tools' own documentation and the classic commands' manuals, only those whose licences allow commercial use (`docs/sources.md`); built by `../free-books-catalog` from `catalog/config.json` |
| `dataset/` | `records.jsonl` and `chat.jsonl`, generated from the pages |
| `src/mcli/` | page parser, example runner, dataset derivation |
| `tools/` | `try_command` (run one command as the tests do), `dataset_build` |
| `docs/spec/` | one table per page: its claims (ID `CLI-<TOOL>-NN`) and the examples that confirm them |
| `docs/adr/` | why: sources (0001), examples run and compared (0002), dataset (0003), only commercially usable sources (0004) |

## Using the skill

Copy or link `skills/modern-cli/` into `~/.claude/skills/` (or a project's `.claude/skills/`).

## Using the dataset

`dataset/records.jsonl` has one record per line: `id`, `kind` (`explain`, `task`, `rewrite`,
`pitfall`, `keep-classic`), `area` (`cli`), `concept` (the page), `instruction`, `input`, `output`,
`specIds`, `sources` (catalog IDs) and `files` (page and line). `dataset/chat.jsonl` holds the same
records as system/user/assistant messages. `specIds` also lists the `CLI-<TOOL>-NN` IDs that the
example names in its `# spec:` line. Pages marked 未検証 give no record. Regenerate with
`nim dataset`.

## Development

Needs Nim 2.4.2, the tools at the versions in `docs/tool-versions.md`, and next to this repository
`../free-books-catalog` (catalog) and `../beautifulnim` (lint).

```sh
nim test           # parser, pages, every example, tool versions, dataset
nim dataset        # dataset/ from the pages
nim catalog        # catalog/ from the fetched pages (no network)
nim specCoverage   # G1 table (needs ../nim-spec-coverage)
bin/try_command 'rg -l --sort path TODO'   # one command, run as the tests run it

# refreshing the sources (network; one request per host at a time, robots.txt honoured)
nim c -d:ssl -d:release -o:bin/catalog_fetch ../free-books-catalog/tools/catalog_fetch.nim
bin/catalog_fetch reach   # reads catalog/config.json
```

The fetched pages live outside the repository: `$MCLI_RAW`, by default
`~/.cache/modern-cli-knowledge/raw`.

## Licence

Apache License 2.0 (`LICENSE`, `NOTICE`): the pages, examples, dataset, code and tests may be used,
changed and built into other systems, commercial ones included. The repository copies no text from
other works; the sources it lists are the tools' documentation and manuals, each under licences that
allow commercial use (`docs/sources.md`), and a test fails if one that does not enters the catalog
(MCLI-SRC-01).
