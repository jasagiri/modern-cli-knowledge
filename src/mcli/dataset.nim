## Deriving training records from the details pages (ADR-MCLI-0003). Pure: pages arrive as
## (name, text) pairs, so the same pages give the same bytes (MCLI-DATA-01). Pages marked 未検証
## give no record (MCLI-DATA-02).

import std/[algorithm, json, options, strutils]
import ./pages

type
  Record* = object
    id*, kind*, topic*, instruction*, input*, output*: string
    specIds*, sources*, files*: seq[string]

const
  systemMessage* = "You are a careful command-line assistant. In interactive work in a repository, " &
    "prefer the modern tools (rg, fd, sd, bat, eza, jq, yq, xh) and say how their results differ " &
    "from the classic commands; in portable scripts, CI and servers without them, keep the POSIX commands."
  pagesDir* = "skills/modern-cli/details/"

func sectionBody(page: Page; heading: string): string {.raises: [].} =
  for s in page.sections:
    if s.heading == heading: return s.body.strip
  ""

func sourceIds(page: Page): seq[string] {.raises: [].} =
  let body = sectionBody(page, "Sources")
  for w in body.multiReplace((",", " "), (".", " "), (";", " "), ("`", " ")).splitWhitespace:
    if w.len == 16 and w.allCharsInSet(HexDigits) and w notin result: result.add w

func proseBefore(lines: seq[string]; fenceLine: int): string {.raises: [].} =
  ## The last prose line above the block that opens at fenceLine (1-based), skipping blank lines;
  ## "" when the nearest non-blank line closes another block or is a heading.
  var i = fenceLine - 2
  while i >= 0 and lines[i].strip.len == 0: dec i
  if i < 0: return ""
  let l = lines[i].strip
  if l.startsWith("```") or l.startsWith("#"): "" else: l

func withoutExitLine(body: string): string {.raises: [].} =
  if body.startsWith("# exit:"):
    let nl = body.find('\n')
    if nl < 0: "" else: body[nl + 1 .. ^1]
  else: body

func answer(ex: Example): string {.raises: [].} =
  result = "```sh\n" & withoutExitLine(ex.command.body) & "```\n\nOutput:\n```text\n" & ex.expected & "```"
  if ex.exitCode != 0: result.add "\n\nExit status: " & $ex.exitCode

func tool(page: Page): string {.raises: [].} =
  let i = page.title.rfind(": ")
  if i < 0: page.title else: page.title[i + 2 .. ^1]

func pad2(n: int): string {.raises: [].} = (if n < 10: "0" & $n else: $n)

func recordsOf*(name, text: string): seq[Record] {.raises: [].} =
  ## The records of one page; none for a page marked 未検証.
  let page = parsePage(text)
  if page.status.len > 0: return @[]
  let topic = name.replace(".md", "")
  let lines = text.splitLines
  let sources = sourceIds(page)
  let file = pagesDir & name
  result.add Record(id: "explain:cli/" & topic, kind: "explain", topic: topic,
    instruction: page.title & ": what is it for, and how do its results differ from the classic command?",
    input: "", output: sectionBody(page, "Intent") & "\n\n" & sectionBody(page, "Differences that change results"),
    specIds: @["MCLI-PAGE-01"], sources: sources, files: @[file])
  result.add Record(id: "keep-classic:cli/" & topic, kind: "keep-classic", topic: topic,
    instruction: "When should I keep the classic command instead of " & tool(page) & "?",
    input: "", output: sectionBody(page, "When to keep the classic command"),
    specIds: @["MCLI-PAGE-01"], sources: sources, files: @[file])
  var nTask, nRewrite, nPitfall = 0
  let blocks = page.blocks
  for ex in examplesOf(page).examples:
    let at = file & ":" & $ex.command.line
    # The block before the command says what kind of example it is.
    var prev = -1
    for j, b in blocks:
      if b.line == ex.command.line: prev = j - 1
    let isBad = prev >= 0 and blocks[prev].kind == bkBad
    if ex.classic.isSome:
      inc nRewrite
      result.add Record(id: "rewrite:cli/" & topic & "#" & pad2(nRewrite), kind: "rewrite", topic: topic,
        instruction: "Rewrite this classic command with " & tool(page) & " so that it prints the same output.",
        input: "```sh\n" & withoutExitLine(ex.classic.get.body) & "```",
        output: answer(ex) & "\n\nWhat differs by default:\n" & sectionBody(page, "Differences that change results"),
        specIds: @["MCLI-EX-01", "MCLI-EX-03"], sources: sources,
        files: @[file & ":" & $ex.classic.get.line, at])
    elif isBad:
      inc nPitfall
      let why = proseBefore(lines, blocks[prev].line)
      result.add Record(id: "pitfall:cli/" & topic & "#" & pad2(nPitfall), kind: "pitfall", topic: topic,
        instruction: "This command does not do what was meant. Fix it." & (if why.len > 0: " (" & why & ")" else: ""),
        input: "```sh\n" & blocks[prev].body & "```", output: answer(ex),
        specIds: @["MCLI-EX-01"], sources: sources, files: @[file & ":" & $blocks[prev].line, at])
    else:
      let what = proseBefore(lines, ex.command.line)
      if what.len == 0: continue
      inc nTask
      result.add Record(id: "task:cli/" & topic & "#" & pad2(nTask), kind: "task", topic: topic,
        instruction: what, input: "", output: answer(ex),
        specIds: (if ex.idempotent: @["MCLI-EX-01", "MCLI-EX-04"] else: @["MCLI-EX-01"]),
        sources: sources, files: @[at])

func toJson*(r: Record): JsonNode {.raises: [].} =
  %*{"id": r.id, "kind": r.kind, "area": "cli", "concept": r.topic, "instruction": r.instruction,
     "input": r.input, "output": r.output, "specIds": r.specIds, "sources": r.sources, "files": r.files}

func toChat*(r: Record): JsonNode {.raises: [].} =
  let user = (if r.input.len > 0: r.instruction & "\n\n" & r.input else: r.instruction)
  %*{"id": r.id, "messages": [
    {"role": "system", "content": systemMessage},
    {"role": "user", "content": user},
    {"role": "assistant", "content": r.output}]}

func render*(pagesIn: openArray[(string, string)]): (string, string) {.raises: [].} =
  ## (records.jsonl, chat.jsonl) for the given pages, sorted by id.
  var all: seq[Record]
  for (name, text) in pagesIn: all.add recordsOf(name, text)
  all.sort(proc (a, b: Record): int = cmp(a.id, b.id))
  for r in all:
    result[0].add $toJson(r) & "\n"
    result[1].add $toChat(r) & "\n"
