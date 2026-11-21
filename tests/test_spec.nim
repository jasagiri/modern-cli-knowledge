## E tests for docs/specification.md MCLI-SPEC-02 and MCLI-SPEC-03 (the spec table of each page,
## docs/spec/<page>.md, against the examples of the page, nim-shell-pages src/shell_pages/spec.nim).

import std/[os, sequtils, strutils, unittest]
import shell_pages/[pages, spec]
import mcli/profile

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
| CLI-RG-02 | D2 | two | 本文のみ (機械: machine dependent) |
| CLI-RG-03 | K1 | keep | 本文のみ (助言: a policy, not a result) |
"""

suite "spec table":
  # SPEC: MCLI-SPEC-02
  test "MCLI-SPEC-02 Given a table that matches its page, when checked, then there are no errors":
    check specErrors(parsePage(page), mcliProfile, table).len == 0

  # SPEC: MCLI-SPEC-02
  test "MCLI-SPEC-02 Given an ID with no example marked 例, when checked, then the ID is named":
    let t = table.replace("CLI-RG-02 | D2 | two | 本文のみ (機械: machine dependent)", "CLI-RG-02 | D2 | two | 例")
    let errs = specErrors(parsePage(page), mcliProfile, t)
    check errs.len == 1
    check "CLI-RG-02" in errs[0]

  # SPEC: MCLI-SPEC-02
  test "MCLI-SPEC-02 Given an example that names an ID missing from the table, when checked, then the ID is named":
    let p = page.replace("# spec: CLI-RG-01", "# spec: CLI-RG-01 CLI-RG-09")
    let errs = specErrors(parsePage(p), mcliProfile, table)
    check errs.len == 1
    check "CLI-RG-09" in errs[0]

  # SPEC: MCLI-SPEC-02
  test "MCLI-SPEC-02 Given a text-only row whose ID an example names, when checked, then it is an error":
    let p = page.replace("# spec: CLI-RG-01", "# spec: CLI-RG-01 CLI-RG-02")
    check specErrors(parsePage(p), mcliProfile, table).len == 1

  # SPEC: MCLI-SPEC-02
  test "MCLI-SPEC-02 Given a text-only row without a reason, a duplicate ID or a wrong tool, when checked, then each is an error":
    check specErrors(parsePage(page), mcliProfile, table.replace("本文のみ (機械: machine dependent)", "本文のみ ()")).len == 1
    check specErrors(parsePage(page), mcliProfile, table.replace("本文のみ (機械: machine dependent)", "本文のみ (機械: )")).len == 1

  # SPEC: MCLI-SPEC-02
  test "MCLI-SPEC-02 Given a text-only reason without a listed category, when checked, then the row is named":
    let missing = specErrors(parsePage(page), mcliProfile, table.replace("(機械: machine dependent)", "(machine dependent)"))
    check missing.len == 1
    check "CLI-RG-02" in missing[0]
    let unknown = specErrors(parsePage(page), mcliProfile, table.replace("(機械: machine dependent)", "(気分: machine dependent)"))
    check unknown.len == 1
    check "CLI-RG-02" in unknown[0]
    for cat in mcliProfile.textOnlyCategories:
      check specErrors(parsePage(page), mcliProfile, table.replace("(機械: machine dependent)", "(" & cat & ": x)")).len == 0
    check specErrors(parsePage(page), mcliProfile, table.replace("CLI-RG-03", "CLI-RG-02")).len >= 1
    check specErrors(parsePage(page), mcliProfile, table.replace("CLI-RG-03", "CLI-FD-03")).len == 1

  # SPEC: MCLI-SPEC-03
  test "MCLI-SPEC-03 Given a bullet no row points at or a row pointing past the bullets, when checked, then it is named":
    let a = specErrors(parsePage(page), mcliProfile, table.replace("| CLI-RG-03 | K1 | keep | 本文のみ (助言: a policy, not a result) |\n", ""))
    check a.len == 1
    check "K1" in a[0]
    let b = specErrors(parsePage(page), mcliProfile, table.replace("| D2 |", "| D3 |"))
    check b.len >= 1

suite "spec table cells":
  # SPEC: MCLI-SPEC-02
  test "MCLI-SPEC-02 Given a claim with an escaped bar, when the table is read, then the bar stays in its cell":
    let t = parseSpecTable("| ID | 箇所 | 主張 | 確かめ |\n|---|---|---|---|\n| CLI-RG-01 | D1 | a \\| b | 例 |\n")
    check t.errors.len == 0
    check t.rows.len == 1
    check t.rows[0].statement == "a | b"
    check t.rows[0].check == "例"

suite "spec table shape":
  const head = "| ID | 箇所 | 主張 | 確かめ |\n|---|---|---|---|\n"

  # SPEC: MCLI-SPEC-02
  test "MCLI-SPEC-02 Given a line ending in a backslash or in an escaped bar, when the table is read, then no cell is lost or invented and nothing is read past the line":
    let trailing = parseSpecTable(head & "| CLI-RG-01 | D1 | a | 例 | x \\\n")
    check trailing.errors.len == 0
    check trailing.rows.len == 1
    let escapedLast = parseSpecTable(head & "| CLI-RG-01 | D1 | a | 例 | x \\|\n")
    check escapedLast.errors.len == 0
    check escapedLast.rows.len == 1

  # SPEC: MCLI-SPEC-02
  test "MCLI-SPEC-02 Given rows above the header, when the table is read, then they are not rows and not errors":
    let t = parseSpecTable("| a | b |\n| only |\n" & head & "| CLI-RG-01 | D1 | a | 例 |\n")
    check t.errors.len == 0
    check t.rows.len == 1

  # SPEC: MCLI-SPEC-02
  test "MCLI-SPEC-02 Given separator rows of any width or alignment, when the table is read, then they are not rows":
    let t = parseSpecTable("| ID | 箇所 | 主張 | 確かめ |\n|---|:---|---:|---|\n|---|\n| CLI-RG-01 | D1 | a | 例 |\n")
    check t.errors.len == 0
    check t.rows.len == 1

  # SPEC: MCLI-SPEC-02
  test "MCLI-SPEC-02 Given a bar-only line and a row of three cells, when the table is read, then each is an error and neither is a row":
    let t = parseSpecTable(head & "|\n| CLI-RG-01 | D1 | a |\n| CLI-RG-02 | D2 | b | 例 |\n")
    check t.errors.len == 2
    check t.rows.len == 1
    check t.rows[0].id == "CLI-RG-02"

  # SPEC: MCLI-SPEC-02
  test "MCLI-SPEC-02 Given a malformed row, when the page is checked against the table, then the row error is reported":
    check specErrors(parsePage(page), mcliProfile, table & "| CLI-RG-04 | D1 | a |\n").len == 1

suite "spec table rules":
  const head = "| ID | 箇所 | 主張 | 確かめ |\n|---|---|---|---|\n"
  const body = """## Intent
x
## Classic and modern
x
## Commands
```sh
# spec: CLI-ZZ-01
true
```
```text
```
## Differences that change results
- one
- two
## When to keep the classic command
- keep
## Pitfalls
x
## Sources
x
"""
  const rows = """| CLI-ZZ-01 | D1 | one | 例 |
| CLI-ZZ-02 | D2 | two | 本文のみ (助言: advice) |
| CLI-ZZ-03 | K1 | keep | 本文のみ (助言: advice) |
"""

  # SPEC: MCLI-SPEC-02
  test "MCLI-SPEC-02 Given a title whose tool is one word, when the IDs are checked, then the title decides the tool whatever the table says":
    for tool in ["rg", "q", "ab12"]:
      let upper = tool.toUpperAscii
      let p = parsePage("# Find: " & tool & "\n" & body.replace("CLI-ZZ-01", "CLI-" & upper & "-01"))
      let ok = rows.replace("CLI-ZZ-", "CLI-" & upper & "-")
      check specErrors(p, mcliProfile, head & ok).len == 0
      let wrong = specErrors(p, mcliProfile, head & rows)
      check wrong.len >= 3
      check "CLI-" & upper & "-NN" in wrong[0]

  # SPEC: MCLI-SPEC-02
  test "MCLI-SPEC-02 Given a title of several tools, when the IDs are checked, then the table's first ID names the tool":
    let p = parsePage("# Find or search: a b\n" & body)
    check specErrors(p, mcliProfile, head & rows).len == 0
    let other = specErrors(p, mcliProfile, head & rows.replace("CLI-ZZ-03", "CLI-YY-03"))
    check other.len == 1
    check "CLI-YY-03" in other[0]
    let single = parsePage("# Find or search: a b\n" & body.replace("- two\n", "").replace("- keep\n", ""))
    check specErrors(single, mcliProfile, head & "| CLI-ZZ-01 | D1 | one | 例 |\n").len == 0
    let none = specErrors(single, mcliProfile, head)
    check none.len == 2  # D1 has no row and the example's ID is not in the table; no crash

  # SPEC: MCLI-SPEC-03
  test "MCLI-SPEC-03 Given a bullet whose row is missing, when checked, then that bullet is named, the first and the last alike":
    let p = parsePage("# Find: zz\n" & body)
    let noFirst = specErrors(p, mcliProfile, head & rows.replace("| CLI-ZZ-01 | D1 | one | 例 |\n", ""))
    check noFirst.anyIt(it.startsWith("D1:"))
    let noLast = specErrors(p, mcliProfile, head & rows.replace("| CLI-ZZ-02 | D2 | two | 本文のみ (助言: advice) |\n", ""))
    check noLast.anyIt(it.startsWith("D2:"))
    check not noLast.anyIt(it.startsWith("D1:"))

  # SPEC: MCLI-SPEC-03
  test "MCLI-SPEC-03 Given a row that points past the bullets or is not of the form D<n>, when checked, then the row is named":
    let p = parsePage("# Find: zz\n" & body)
    let past = specErrors(p, mcliProfile, head & rows.replace("| D2 |", "| D3 |"))
    check past.filterIt("CLI-ZZ-02" in it).len == 1
    let junk = specErrors(p, mcliProfile, head & rows.replace("| D1 |", "| D1x |"))
    check junk.filterIt("CLI-ZZ-01" in it).len == 1
    let letterOnly = specErrors(p, mcliProfile, head & rows.replace("| D1 |", "| Dx |"))
    check letterOnly.filterIt("CLI-ZZ-01" in it).len == 1

  # SPEC: MCLI-SPEC-02
  test "MCLI-SPEC-02 Given a row with an empty claim, when checked, then the row is named; a one-character claim is fine":
    let p = parsePage("# Find: zz\n" & body)
    let empty = specErrors(p, mcliProfile, head & rows.replace("| one |", "|  |"))
    check empty.len == 1
    check "CLI-ZZ-01" in empty[0]
    check specErrors(p, mcliProfile, head & rows.replace("| one |", "| x |")).len == 0

  # SPEC: MCLI-SPEC-02
  test "MCLI-SPEC-02 Given a 確かめ cell that is neither 例 nor a complete 本文のみ, when checked, then the row is named":
    let p = parsePage("# Find: zz\n" & body)
    for bad in ["たぶん", "本文のみ (助言: advice", "advice)", "本文のみ"]:
      let errs = specErrors(p, mcliProfile, head & rows.replace("本文のみ (助言: advice) |\n| CLI-ZZ-03", bad & " |\n| CLI-ZZ-03"))
      check errs.len == 1
      check "CLI-ZZ-02" in errs[0]

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
      let errs = specErrors(parsePage(readFile(f)), mcliProfile, readFile(tablePath))
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
