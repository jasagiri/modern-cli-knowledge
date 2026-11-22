# ADR-MCLI-0004: Only sources whose licence allows commercial use

**ADR ID**: ADR-MCLI-0004
**Status**: accepted
**Date**: 2026-11-22
**Author**: jasagiri (drafted by Claude Opus 5.5)

## Context

ADR-MCLI-0001 built the catalog from the free-programming-books sections on the shell and Unix plus
the tools' manuals: about eleven thousand entries, many under terms that forbid commercial use or
state no licence. The pages cited some of them: the POSIX utilities index (its terms allow reading,
not reuse), The Linux Command Line (CC BY-NC-ND), Data Science at the Command Line, Pro Git
(CC BY-NC-SA), Regular Expressions for Regular Folk and The Art of Unix Programming. unix-admin-knowledge
had already been limited to commercially usable sources (ADR-UADM-0004), and jasagiri asked on
2026-11-22 for the other repositories to be limited the same way.

## Requirements

- Every source the repository lists can be used commercially, for example built into a company's
  own systems.
- A source without such a licence cannot enter the catalog, and a test fails if one is committed.
- Every page still cites a source for what it teaches.
- One list of allowed licences for all the knowledge repositories.

## Options

- A. Switch free-programming-books off, list only the tools' documentation and the classic commands'
  manuals with their licences, set `"commercialOnly": true` so free-books-catalog refuses any other,
  and re-cite the pages.
- B. Keep free-programming-books and keep only the entries whose list line states an allowed licence.
- C. Keep the catalog and drop only the citations of sources that are not usable commercially.

## Trade-offs

- A cites the primary documentation of each command, which is what the pages' claims rest on, and
  the builder enforces the rule. The classic commands need manuals added (GNU manuals, Git, Ubuntu
  manual pages).
- B keeps more sources, but most list lines state no licence, and a stated licence is the list
  maintainers' reading, not the source's own terms.
- C still ships a catalog listing works that cannot be used commercially.

## Decision

A.

- `catalog/config.json` has `"fpb": false`, `"hillside": false` and `"commercialOnly": true`; the
  catalog is exactly the 40 listed sources (MCLI-SRC-02).
- Each listed source carries the SPDX identifiers of its licences, read from the source itself
  (`docs/sources.md` says where for each kind); every one must be in free-books-catalog's
  `commercialLicenses` (MCLI-SRC-01).
- The classic side of each page cites the GNU Coreutils, Diffutils, findutils, grep, sed and Bash
  manuals, the Git reference manual, or the Ubuntu 24.04 manual page of the command (tar, mawk, ssh,
  scp, ssh-keygen, apropos, top, ps, kill, iostat, ping, tree, curl, less). The five pages that had
  no citation now have one.
- The pages copy no text from these sources (ADR-MCLI-0001).

## Not decided here

- Whether to cite the BSD manual pages of the classic tools as well; the examples run on macOS, but
  the BSD pages' licences were not read.

## Rejected alternatives

B and C, for the reasons under Trade-offs.

## 訂正 (2026-11-22)

- The pages' statements about POSIX were checked against the listed sources. The GNU findutils
  manual already supports those in combine.md (`-exec ... +` in POSIX, `-print0` and `xargs -0`
  from Issue 8). processes.md now also cites the GNU Bash manual (asynchronous commands ignore INT
  and QUIT without job control) and the Wikipedia article on signals (the portable signal
  numbers); file-operations.md now says what the GNU Coreutils manual says about `cp -r`. The
  catalog lists 41 sources.
