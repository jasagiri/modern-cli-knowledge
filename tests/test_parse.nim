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
    for bad in ["# exit: x", "# exit: 256", "# exit:", "# exit: 1234"]:
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
