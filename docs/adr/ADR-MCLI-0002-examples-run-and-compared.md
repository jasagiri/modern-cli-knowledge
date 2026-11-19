# ADR-MCLI-0002: Every example is run and compared

**ADR ID**: ADR-MCLI-0002
**Status**: accepted
**Date**: 2026-11-19
**Author**: jasagiri (drafted by Claude Opus 5.5)

## Context

A command that looks right but prints something else is the typical error of a small model with
the shell: `rg` skipping ignored files, `fd` printing in another order, `sed -i` differing between
BSD and GNU. Text written from memory repeats these errors.

## Requirements

- Every command shown as working is run by the tests, and its output is compared byte for byte.
- The same page gives the same result on every run: fixed input tree, environment and order.
- A tool upgrade that changes output is noticed.
- Tools that cannot be run here are still described, clearly marked, and kept out of the dataset.

## Options

1. **Examples as prose**, checked by review. No machinery; errors survive review.
2. **Golden files** per example next to the pages. Run and compared; the page and its expected
   output live apart and drift.
3. **Expected output inside the page**: a ```sh block followed by its ```text block, run in a fresh
   copy of `fixtures/tree` by `tests/test_examples.nim`.

## Trade-offs

Option 3 makes pages longer and binds them to the fixture, and every example must make its order
explicit (`--sort path`, `| sort`). In exchange the page is its own test, and what a reader sees is
exactly what ran.

## Decision

Option 3, with these rules (MCLI-PAGE-02, MCLI-PAGE-03, MCLI-EX-01…05, MCLI-VER-01):

- Blocks: ```sh then ```text; ```sh classic then ```sh then ```text for a rewrite pair (both must
  print the text); ```sh bad then the fix and its ```text; ```sh idempotent when running twice
  must equal running once; `# exit: N` as the first line when the status is not 0.
- Run: `/bin/sh -c` with standard input from /dev/null, in a fresh copy of `fixtures/tree` where
  each `_gitignore` is renamed `.gitignore` and an empty `.git` directory marks the root as a
  repository; `env -i` with `PATH`, `HOME` inside the copy, `LC_ALL=C.UTF-8`, `TZ=UTC`,
  `NO_COLOR=1`, `TERM=dumb`, `PAGER=cat`. Only standard output is compared; standard error is shown
  when a comparison fails.
- The fixture keeps `_gitignore` so that the repository's own version control does not apply it.
- Versions: `docs/tool-versions.md` records the version line of every verified tool, and a test
  compares it.
- Not runnable here (not installed, interactive, or output that depends on the machine: running
  processes, mounts, timings, the network): the page says `Status: 未検証 (<reason>)` and uses
  ```sh unverified only.
- The classic commands are the BSD ones of the checking machine (macOS). GNU differences are
  described, not run.

## Not decided here

- Running the examples on Linux with GNU classic tools as a second platform.

## Rejected alternatives

Options 1 and 2 above.
