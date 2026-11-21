## E tests for docs/specification.md MCLI-VER-01 (the recorded tool versions).

import std/[os, strutils, unittest]
import shell_pages/runner

const root = currentSourcePath().parentDir.parentDir

suite "versions":
  # SPEC: MCLI-VER-01
  test "MCLI-VER-01 Given each verified tool in docs/tool-versions.md, when its version command runs, then the recorded line matches":
    let work = getTempDir() / "mcli-versions-" & $getCurrentProcessId()
    createDir(work)
    var checked = 0
    for line in readFile(root / "docs" / "tool-versions.md").splitLines:
      let cells = line.split('|')
      if cells.len < 7 or cells[5].strip != "verified": continue
      let tool = cells[1].strip
      let command = cells[2].strip.strip(chars = {'`'})
      let lineNo = cells[3].strip.parseInt
      let recorded = cells[4].strip.strip(chars = {'`'})
      let r = run(work, command & " 2>&1")
      let lines = r.stdout.splitLines
      let actual = (if lineNo - 1 < lines.len: lines[lineNo - 1] else: "")
      if actual != recorded: echo tool, ": recorded '", recorded, "', now '", actual, "'"
      check actual == recorded
      inc checked
    removeDir(work)
    check checked > 0
