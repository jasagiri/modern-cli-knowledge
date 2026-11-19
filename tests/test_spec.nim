## E tests for docs/specification.md MCLI-SPEC-02 and MCLI-SPEC-03 (the spec table of each page,
## docs/spec/<page>.md, against the examples of the page, src/mcli/spec.nim).

import std/[os, strutils, unittest]
import mcli/[pages, spec]

const root = currentSourcePath().parentDir.parentDir

const page = """# Find: rg
## Intent
x
## Classic and modern
x
## Commands
```sh
# spec: CLI-RG-01
rg a
```
```text
a
```
## Differences that change results
- one
- two
```sh
- not a bullet
```
## When to keep the classic command
- keep
## Pitfalls
x
## Sources
x
"""

const table = """# Spec: rg

| ID | 箇所 | 主張 | 確かめ |
|---|---|---|---|
| CLI-RG-01 | D1 | one | 例 |
| CLI-RG-02 | D2 | two | 本文のみ (machine dependent) |
| CLI-RG-03 | K1 | keep | 本文のみ (a policy, not a result) |
"""

suite "spec table":
  # SPEC: MCLI-SPEC-02
  test "MCLI-SPEC-02 Given a table that matches its page, when checked, then there are no errors":
    check specErrors(parsePage(page), table).len == 0

  # SPEC: MCLI-SPEC-02
  test "MCLI-SPEC-02 Given an ID with no example marked 例, when checked, then the ID is named":
    let t = table.replace("CLI-RG-02 | D2 | two | 本文のみ (machine dependent)", "CLI-RG-02 | D2 | two | 例")
    let errs = specErrors(parsePage(page), t)
    check errs.len == 1
    check "CLI-RG-02" in errs[0]

  # SPEC: MCLI-SPEC-02
  test "MCLI-SPEC-02 Given an example that names an ID missing from the table, when checked, then the ID is named":
    let p = page.replace("# spec: CLI-RG-01", "# spec: CLI-RG-01 CLI-RG-09")
    let errs = specErrors(parsePage(p), table)
    check errs.len == 1
    check "CLI-RG-09" in errs[0]

  # SPEC: MCLI-SPEC-02
  test "MCLI-SPEC-02 Given a text-only row whose ID an example names, when checked, then it is an error":
    let p = page.replace("# spec: CLI-RG-01", "# spec: CLI-RG-01 CLI-RG-02")
    check specErrors(parsePage(p), table).len == 1

  # SPEC: MCLI-SPEC-02
  test "MCLI-SPEC-02 Given a text-only row without a reason, a duplicate ID or a wrong tool, when checked, then each is an error":
    check specErrors(parsePage(page), table.replace("本文のみ (machine dependent)", "本文のみ ()")).len == 1
    check specErrors(parsePage(page), table.replace("CLI-RG-03", "CLI-RG-02")).len >= 1
    check specErrors(parsePage(page), table.replace("CLI-RG-03", "CLI-FD-03")).len == 1

  # SPEC: MCLI-SPEC-03
  test "MCLI-SPEC-03 Given a bullet no row points at or a row pointing past the bullets, when checked, then it is named":
    let a = specErrors(parsePage(page), table.replace("| CLI-RG-03 | K1 | keep | 本文のみ (a policy, not a result) |\n", ""))
    check a.len == 1
    check "K1" in a[0]
    let b = specErrors(parsePage(page), table.replace("| D2 |", "| D3 |"))
    check b.len >= 1

suite "spec table cells":
  # SPEC: MCLI-SPEC-02
  test "MCLI-SPEC-02 Given a claim with an escaped bar, when the table is read, then the bar stays in its cell":
    let t = parseSpecTable("| ID | 箇所 | 主張 | 確かめ |\n|---|---|---|---|\n| CLI-RG-01 | D1 | a \\| b | 例 |\n")
    check t.errors.len == 0
    check t.rows.len == 1
    check t.rows[0].statement == "a | b"
    check t.rows[0].check == "例"

suite "committed spec tables":
  # SPEC: MCLI-SPEC-02
  # SPEC: MCLI-SPEC-03
  test "MCLI-SPEC-02 Given every details page, when its docs/spec table is read, then the table and the examples agree":
    var checked = 0
    for f in walkFiles(root / "skills" / "modern-cli" / "details" / "*.md"):
      let stem = f.extractFilename.replace(".md", "")
      let tablePath = root / "docs" / "spec" / stem & ".md"
      check fileExists(tablePath)
      if not fileExists(tablePath): continue
      let errs = specErrors(parsePage(readFile(f)), readFile(tablePath))
      for e in errs: echo stem, ": ", e
      check errs.len == 0
      inc checked
    check checked > 0

  # SPEC: MCLI-SPEC-02
  test "MCLI-SPEC-02 Given all the tables, when the IDs are collected, then no ID is in two tables":
    var seen: seq[string]
    for f in walkFiles(root / "docs" / "spec" / "*.md"):
      for r in parseSpecTable(readFile(f)).rows:
        check r.id notin seen
        seen.add r.id
