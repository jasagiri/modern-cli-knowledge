## dataset_build [--root:<repo>]
##
## skills/modern-cli/details/*.md → dataset/records.jsonl and dataset/chat.jsonl (ADR-MCLI-0003).
## No network, no clock (MCLI-DATA-01). Exit 0 on success, 2 on a usage error.

import std/[algorithm, os, parseopt]
import mcli/dataset

proc main() =
  var root = getCurrentDir()
  for kind, key, val in getopt():
    if kind == cmdLongOption and key == "root": root = val
    else:
      stderr.writeLine "usage: dataset_build [--root:<repo>]"
      quit 2
  var names: seq[string]
  for f in walkFiles(root / pagesDir / "*.md"): names.add f.extractFilename
  names.sort()
  var pagesIn: seq[(string, string)]
  for n in names: pagesIn.add (n, readFile(root / pagesDir / n))
  let (records, chat) = render(pagesIn)
  createDir(root / "dataset")
  writeFile(root / "dataset" / "records.jsonl", records)
  writeFile(root / "dataset" / "chat.jsonl", chat)
  var count = 0
  for c in records:
    if c == '\n': inc count
  echo "dataset_build: ", count, " records → ", root / "dataset"

main()
