## E tests for docs/specification.md MCLI-PAGE-03 (block pairing in nim-shell-pages src/shell_pages/pages.nim).

import std/[options, strutils, unittest]
import shell_pages/pages
import mcli/profile

func page(blocks: string; status = ""): string =
  "# T\n" & (if status.len > 0: "Status: 未検証 (" & status & ")\n" else: "") &
    "\n## Commands\n\n" & blocks

suite "pairing":
  # SPEC: MCLI-PAGE-03
  test "MCLI-PAGE-03 Given sh then text, when paired, then one example with status 0":
    let ex = examplesOf(parsePage(page("```sh\nrg x\n```\n```text\nout\n```\n")), mcliProfile)
    check ex.errors.len == 0
    check ex.examples.len == 1
    check ex.examples[0].command.body == "rg x\n"
    check ex.examples[0].expected == "out\n"
    check ex.examples[0].exitCode == 0
    check ex.examples[0].classic.isNone

  # SPEC: MCLI-PAGE-03
  test "MCLI-PAGE-03 Given classic, sh and text, when paired, then the classic command shares the text":
    let ex = examplesOf(parsePage(page("```sh classic\ngrep x\n```\n```sh\nrg x\n```\n```text\nout\n```\n")), mcliProfile)
    check ex.errors.len == 0
    check ex.examples.len == 1
    check ex.examples[0].classic.get.body == "grep x\n"

  # SPEC: MCLI-PAGE-03
  test "MCLI-PAGE-03 Given bad, fix and text, when paired, then only the fix runs":
    let ex = examplesOf(parsePage(page("```sh bad\nrg (\n```\n```sh\nrg -F (\n```\n```text\n```\n")), mcliProfile)
    check ex.errors.len == 0
    check ex.examples.len == 1
    check ex.examples[0].command.body == "rg -F (\n"
    check ex.examples[0].classic.isNone
    check ex.examples[0].expected == ""

  # SPEC: MCLI-PAGE-03
  test "MCLI-PAGE-03 Given an exit line, when paired, then the example expects that status; a malformed one is an error":
    check examplesOf(parsePage(page("```sh\n# exit: 1\nrg NOPE\n```\n```text\n```\n")), mcliProfile).examples[0].exitCode == 1
    check examplesOf(parsePage(page("```sh\n# exit: 007\nrg NOPE\n```\n```text\n```\n")), mcliProfile).examples[0].exitCode == 7
    for bad in ["# exit: x", "# exit: 256", "# exit:", "# exit: 1234", "# exit: 0001"]:
      let ex = examplesOf(parsePage(page("```sh\n" & bad & "\nrg\n```\n```text\n```\n")), mcliProfile)
      check ex.errors.len == 1
      check ex.examples.len == 0

  # SPEC: MCLI-PAGE-03
  test "MCLI-PAGE-03 Given broken pairings, when paired, then each is an error naming its line":
    let cases = [
      ("```sh\nrg x\n```\n", 5),                                   # no text after sh
      ("```text\nout\n```\n", 5),                                  # text after nothing
      ("```sh classic\ngrep x\n```\n```text\nout\n```\n", 5),      # classic without modern
      ("```sh bad\nrg (\n```\n", 5),                               # bad without fix
      ("```sh unverified\nzoxide\n```\n", 5)]                      # unverified on a verified page
    for (blocks, line) in cases:
      let ex = examplesOf(parsePage(page(blocks)), mcliProfile)
      check ex.errors.len >= 1
      check ex.errors[0].line == line

  # SPEC: MCLI-PAGE-03
  test "MCLI-PAGE-03 Given a page marked 未検証, when paired, then unverified blocks pass and runnable ones are errors":
    let ok = examplesOf(parsePage(page("```sh unverified\nz foo\n```\n", "not installed")), mcliProfile)
    check ok.errors.len == 0
    check ok.examples.len == 0
    check parsePage(page("", "not installed")).status == "not installed"
    let bad = examplesOf(parsePage(page("```sh\nrg x\n```\n```text\n```\n", "not installed")), mcliProfile)
    check bad.errors.len == 1

  # SPEC: MCLI-PAGE-01
  test "MCLI-PAGE-01 Given a page missing or reordering a section, when checked, then the section is named":
    var full = "# T\n"
    for s in mcliProfile.requiredSections: full.add "\n## " & s & "\nx\n"
    check sectionOrderErrors(parsePage(full), mcliProfile).len == 0
    let swapped = full.replace("## Pitfalls", "## Tmp").replace("## Commands", "## Pitfalls").replace("## Tmp", "## Commands")
    check sectionOrderErrors(parsePage(swapped), mcliProfile).len > 0
    check sectionOrderErrors(parsePage(full.replace("## Sources", "## Refs")), mcliProfile) == @["missing or out of order: ## Sources"]

suite "spec header":
  # SPEC: MCLI-SPEC-01
  test "MCLI-SPEC-01 Given spec comment lines at the top of a command, when paired, then the example names those IDs":
    let ex = examplesOf(parsePage(page("```sh\n# spec: CLI-RG-01 CLI-RG-02\nrg x\n```\n```text\nout\n```\n")), mcliProfile)
    check ex.errors.len == 0
    check ex.examples[0].specs == @["CLI-RG-01", "CLI-RG-02"]
    check ex.examples[0].exitCode == 0

  # SPEC: MCLI-SPEC-01
  test "MCLI-SPEC-01 Given an exit line and spec lines in either order, when paired, then both are read":
    for body in ["# exit: 1\n# spec: CLI-RG-03\n", "# spec: CLI-RG-03\n# exit: 1\n"]:
      let ex = examplesOf(parsePage(page("```sh\n" & body & "rg NOPE\n```\n```text\n```\n")), mcliProfile)
      check ex.errors.len == 0
      check ex.examples[0].exitCode == 1
      check ex.examples[0].specs == @["CLI-RG-03"]
      check withoutHeader(body & "rg NOPE\n") == "rg NOPE\n"

  # SPEC: MCLI-SPEC-01
  test "MCLI-SPEC-01 Given a malformed spec line, when paired, then it is an error naming the line":
    for bad in ["# spec:", "# spec: rg-1", "# spec: CLI-RG-1", "# spec: CLI-RG-01,CLI-RG-02"]:
      let ex = examplesOf(parsePage(page("```sh\n" & bad & "\nrg\n```\n```text\n```\n")), mcliProfile)
      check ex.errors.len == 1
      check ex.examples.len == 0

suite "block shapes":
  func lines(errs: seq[PageError]): seq[int] =
    for e in errs: result.add e.line

  # SPEC: MCLI-PAGE-03
  test "MCLI-PAGE-03 Given fences with no info or another language, when paired, then they are ignored":
    let p = parsePage(page("```\nplain\n```\n```json\n{}\n```\n```sh\nrg\n```\n```text\no\n```\n"))
    check p.blocks[0].kind == bkOther
    check p.blocks[1].kind == bkOther
    let ex = examplesOf(p, mcliProfile)
    check ex.errors.len == 0
    check ex.examples.len == 1

  # SPEC: MCLI-PAGE-01
  test "MCLI-PAGE-01 Given a block above the first section or inside one, when parsed, then the section body holds its own lines only":
    let early = parsePage("# T\n```sh\nrg\n```\n## A\n")
    check early.blocks.len == 1
    check early.sections.len == 1
    check early.sections[0].body.strip == ""
    let inside = parsePage("# T\n## A\nx\n```sh\nrg\n```\n")
    check inside.sections[0].body.strip == "x\n```sh\nrg\n```"

  # SPEC: MCLI-PAGE-01
  test "MCLI-PAGE-01 Given several `# ` lines or prose above the title, when parsed, then the title is the first `# ` line":
    check parsePage("# First\n# Second\n").title == "First"
    check parsePage("prose\n# T\n").title == "T"

  # SPEC: MCLI-SPEC-01
  test "MCLI-SPEC-01 Given spec IDs that are not CLI-<TOOL>-NN with an upper-case or digit tool and two digits, when paired, then each is an error":
    for bad in ["# spec: CLI--01", "# spec: CLI-rg-01", "# spec: CLI-RG-1a", "# spec: CLI-R!-01", "# spec: CLI-RG-01-02"]:
      let ex = examplesOf(parsePage(page("```sh\n" & bad & "\nrg\n```\n```text\n```\n")), mcliProfile)
      check ex.errors.len == 1
    for good in ["# spec: CLI-Q-01", "# spec: CLI-R2-01"]:
      let ex = examplesOf(parsePage(page("```sh\n" & good & "\nrg\n```\n```text\n```\n")), mcliProfile)
      check ex.errors.len == 0

  # SPEC: MCLI-PAGE-03
  test "MCLI-PAGE-03 Given two exit lines in one command, when paired, then it is an error":
    let ex = examplesOf(parsePage(page("```sh\n# exit: 1\n# exit: 1\nrg\n```\n```text\n```\n")), mcliProfile)
    check ex.errors.len == 1
    check ex.examples.len == 0

  # SPEC: MCLI-PAGE-02
  test "MCLI-PAGE-02 Given a page marked 未検証 with a one-character reason, when paired, then a runnable command is an error":
    let ex = examplesOf(parsePage(page("```sh\nrg x\n```\n```text\n```\n", "x")), mcliProfile)
    check ex.errors.len == 1

  # SPEC: MCLI-PAGE-02
  test "MCLI-PAGE-02 Given runnable commands of every pairing on a page marked 未検証, when paired, then each command is one error and its text is not another":
    let blocks = "```sh\na\n```\n```text\no\n```\n" & "```sh\nb\n```\n" & "```sh\nc\n```\n```text\no\n```\n" & "```sh\nd\n```\n"
    let ex = examplesOf(parsePage(page(blocks, "x")), mcliProfile)
    # the page has one more line (the status) above the blocks: the commands open at 6, 12, 15, 21
    check lines(ex.errors) == @[6, 12, 15, 21]

  # SPEC: MCLI-PAGE-03
  test "MCLI-PAGE-03 Given a classic or bad block and a command with no text at the end of the page, when paired, then it is an error naming the line":
    for kind in ["classic", "bad"]:
      let ex = examplesOf(parsePage(page("```sh " & kind & "\ngrep x\n```\n```sh\nrg x\n```\n")), mcliProfile)
      check ex.errors.len == 2  # the pair is broken, then the command alone
      check ex.errors[0].line == 5

  # SPEC: MCLI-PAGE-03
  test "MCLI-PAGE-03 Given a classic pair whose command has a malformed exit line, when paired, then the error names the command's line":
    let ex = examplesOf(parsePage(page("```sh classic\ngrep x\n```\n```sh\n# exit: x\nrg x\n```\n```text\no\n```\n")), mcliProfile)
    check ex.errors.len == 1
    check ex.errors[0].line == 8
    check ex.examples.len == 0

  # SPEC: MCLI-PAGE-03
  test "MCLI-PAGE-03 Given a classic pair, when its command is idempotent or not, then the example says so":
    let idem = examplesOf(parsePage(page("```sh classic\ngrep x\n```\n```sh idempotent\nrg x\n```\n```text\no\n```\n")), mcliProfile)
    check idem.examples[0].idempotent
    let plain = examplesOf(parsePage(page("```sh classic\ngrep x\n```\n```sh\nrg x\n```\n```text\no\n```\n")), mcliProfile)
    check not plain.examples[0].idempotent
