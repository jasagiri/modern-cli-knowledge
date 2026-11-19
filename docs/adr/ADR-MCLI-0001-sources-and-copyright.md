# ADR-MCLI-0001: Sources, citations and copyright

**ADR ID**: ADR-MCLI-0001
**Status**: accepted
**Date**: 2026-11-19
**Author**: jasagiri (drafted by Claude Opus 5.5)

## Context

The pages teach how to use modern command-line tools. Small models trained or prompted with them
must get commands that work, so each page must rest on the tools' own documentation and on books
that teach the shell, without copying their text.

## Requirements

- Every claim about a tool can be traced to its manual or to a listed book.
- No text or code is copied from a manual or book; the repository stays Apache-2.0.
- The list of sources is rebuilt the same way each time, by the code that nim-cs-knowledge uses.

## Options

1. **Write from memory**, cite nothing. Fast; claims cannot be traced and drift with tool versions.
2. **Quote the manuals.** Traceable; copies text under each tool's licence.
3. **Catalog plus original writing.** A catalog built by free-books-catalog from the
   free-programming-books sections on the shell and Unix and from the tools' official manuals
   (listed in `catalog/config.json`); pages written here and citing catalog IDs; every example run
   (ADR-MCLI-0002), so the run, not memory, settles what a command prints.

## Trade-offs

Option 3 costs a catalog build and a citing step, and the tools' manuals are web pages that change.
It keeps the text ours and the facts traceable, and the examples themselves are the strongest
evidence.

## Decision

Option 3. `catalog/config.json` pins the free-programming-books commit, its triage keywords
(shell, Unix, Linux, command line, awk, sed, regular expressions) and the listed manuals. No crawl
of the Hillside catalog (`"hillside": false`). Fetched pages stay in the cache
(`$MCLI_RAW`, by default `~/.cache/modern-cli-knowledge/raw`), never in the repository.

## Not decided here

- Whether to cite man pages of the BSD and GNU classic tools individually.

## Rejected alternatives

Options 1 and 2 above.
