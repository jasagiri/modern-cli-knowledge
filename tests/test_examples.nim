## E tests for docs/specification.md MCLI-PAGE-01, 02, 04, 05 and MCLI-EX-01…05: every page has the
## required shape, and every example prints its ```text in a fresh copy of fixtures/tree.

import std/[json, os, sets, strutils, unittest]
import shell_pages/[pages, runner]
import mcli/profile

const root = currentSourcePath().parentDir.parentDir
let detailsDir = root / "skills" / "modern-cli" / "details"
let fixture = root / "fixtures" / "tree"
let work = getTempDir() / "mcli-examples-" & $getCurrentProcessId()

proc detailPages(): seq[string] =
  for f in walkFiles(detailsDir / "*.md"): result.add f

proc catalogIds(): HashSet[string] =
  let path = root / "catalog" / "sources.jsonl"
  if fileExists(path):
    for line in readFile(path).splitLines:
      if line.len > 0: result.incl parseJson(line)["id"].getStr

suite "pages":
  # SPEC: MCLI-PAGE-01
  test "MCLI-PAGE-01 Given every details page, when its sections are read, then the required ones appear in order":
    check detailPages().len > 0
    for f in detailPages():
      let page = parsePage(readFile(f))
      check page.title.len > 0
      let errs = sectionOrderErrors(page, mcliProfile)
      if errs.len > 0: echo f.extractFilename, ": ", errs
      check errs.len == 0

  # SPEC: MCLI-PAGE-02
  # SPEC: MCLI-PAGE-03
  test "MCLI-PAGE-02 Given every details page, when its blocks are paired, then it follows the block rules and its status":
    for f in detailPages():
      let page = parsePage(readFile(f))
      let ex = examplesOf(page, mcliProfile)
      for e in ex.errors: echo f.extractFilename, ":", e.line, ": ", e.message
      check ex.errors.len == 0
      if page.status.len == 0:
        check ex.examples.len > 0
      else:
        check ex.examples.len == 0

  # SPEC: MCLI-PAGE-04
  test "MCLI-PAGE-04 Given SKILL.md, when its links are read, then every details page is linked and every link exists":
    let skill = readFile(root / "skills" / "modern-cli" / "SKILL.md")
    for f in detailPages():
      check ("details/" & f.extractFilename) in skill
    var i = skill.find("details/")
    while i >= 0:
      let stop = skill.find(".md", i)
      check stop > i
      check fileExists(root / "skills" / "modern-cli" / skill[i .. stop + 2])
      i = skill.find("details/", stop)

  # SPEC: MCLI-PAGE-05
  test "MCLI-PAGE-05 Given every page's Sources, when read, then each catalog ID exists or the section says why there is none":
    let ids = catalogIds()
    for f in detailPages():
      let page = parsePage(readFile(f))
      var body = ""
      for s in page.sections:
        if s.heading == "Sources": body = s.body
      if body.contains("None in the catalog:"): continue
      var found = 0
      for word in body.multiReplace((",", " "), (".", " "), (";", " "), ("`", " ")).splitWhitespace:
        if word.len == 16 and word.allCharsInSet(HexDigits):
          inc found
          check word in ids
      check found > 0

suite "examples":
  let before = snapshot(fixture)

  # SPEC: MCLI-EX-01
  # SPEC: MCLI-EX-02
  # SPEC: MCLI-EX-03
  # SPEC: MCLI-EX-04
  test "MCLI-EX-01 Given every example, when run in a fresh copy of the fixture, then it prints its text and ends with its status":
    var count = 0
    for f in detailPages():
      for ex in examplesOf(parsePage(readFile(f)), mcliProfile).examples:
        inc count
        let outcome = checkExample(fixture, work, ex)
        if not outcome.ok: echo f.extractFilename, ": ", outcome.message
        check outcome.ok
    removeDir(work)
    check count > 0

  # SPEC: MCLI-EX-05
  test "MCLI-EX-05 Given the examples have run, when the fixture is read, then it is unchanged":
    check snapshot(fixture) == before
