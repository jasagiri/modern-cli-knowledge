## E tests for docs/specification.md MCLI-DATA-01…MCLI-DATA-03 (the dataset).

import std/[algorithm, json, os, strutils, unittest]
import mcli/dataset

const root = currentSourcePath().parentDir.parentDir

proc committedPages(): seq[(string, string)] =
  var names: seq[string]
  for f in walkFiles(root / pagesDir / "*.md"): names.add f.extractFilename
  names.sort()
  for n in names: result.add (n, readFile(root / pagesDir / n))

const verified = """# Find: tool
## Intent
Why.
## Classic and modern
x
## Commands
List things:
```sh
ls
```
```text
a
```
```sh classic
grep -l a .
```
```sh
rg -l a
```
```text
a
```
## Differences that change results
- hidden files
## When to keep the classic command
In scripts.
## Pitfalls
Regex:
```sh bad
rg (
```
```sh
# exit: 1
rg -F (
```
```text
```
## Sources
Catalog: 0123456789abcdef.
"""

suite "dataset":
  # SPEC: MCLI-DATA-01
  test "MCLI-DATA-01 Given the committed pages, when the dataset is rebuilt, then it equals the committed files":
    let (records, chat) = render(committedPages())
    check records == readFile(root / "dataset" / "records.jsonl")
    check chat == readFile(root / "dataset" / "chat.jsonl")

  # SPEC: MCLI-DATA-01
  test "MCLI-DATA-01 Given the same pages in another order, when rendered twice, then the bytes are equal":
    let a = render([("a.md", verified), ("b.md", verified)])
    let b = render([("b.md", verified), ("a.md", verified)])
    check a == b

  # SPEC: MCLI-DATA-02
  test "MCLI-DATA-02 Given a verified page, when derived, then each kind comes from its block and the exit status is stated":
    let rs = recordsOf("find.md", verified)
    var kinds: seq[string]
    for r in rs: kinds.add r.kind
    check kinds == @["explain", "keep-classic", "task", "rewrite", "pitfall"]
    check rs[2].instruction == "List things:"
    check rs[2].output.startsWith("```sh\nls\n```")
    check rs[3].input == "```sh\ngrep -l a .\n```"
    check rs[3].output.startsWith("```sh\nrg -l a\n```")
    check rs[4].input == "```sh\nrg (\n```"
    check "# exit:" notin rs[4].output
    check rs[4].output.endsWith("Exit status: 1")
    check rs[0].sources == @["0123456789abcdef"]
    check rs[2].files == @["skills/modern-cli/details/find.md:8"]

  # SPEC: MCLI-DATA-02
  test "MCLI-DATA-02 Given a page marked 未検証, when derived, then it gives no record":
    let page = verified.replace("# Find: tool\n", "# Find: tool\nStatus: 未検証 (not installed)\n")
    check recordsOf("find.md", page).len == 0

  # SPEC: MCLI-DATA-02
  test "MCLI-DATA-02 Given the committed dataset, when read, then no record comes from an unverified page":
    for line in readFile(root / "dataset" / "records.jsonl").splitLines:
      if line.len == 0: continue
      let j = parseJson(line)
      let file = j["files"][0].getStr.split(':')[0]
      check "Status: 未検証" notin readFile(root / file)

  # SPEC: MCLI-DATA-03
  test "MCLI-DATA-03 Given the committed chat file, when read, then each line is a system/user/assistant triple matching its record":
    let records = readFile(root / "dataset" / "records.jsonl").strip.splitLines
    let chats = readFile(root / "dataset" / "chat.jsonl").strip.splitLines
    check records.len == chats.len
    for i in 0 ..< records.len:
      let r = parseJson(records[i])
      let c = parseJson(chats[i])
      check c["id"] == r["id"]
      check c["messages"].len == 3
      check c["messages"][0]["role"].getStr == "system"
      check c["messages"][1]["role"].getStr == "user"
      check c["messages"][2]["role"].getStr == "assistant"
      check c["messages"][2]["content"] == r["output"]
