## Reading a details page: its sections, its fenced blocks and the examples they form
## (ADR-MCLI-0002). Pure: the page arrives as a string, so the same page always gives the same
## examples or the same errors. Running the examples is the test's job (tests/test_examples.nim).
##
## Block info strings:
##   ```sh             a command, run in a fresh copy of fixtures/tree; the next block must be ```text
##   ```sh idempotent  the same, and running it twice leaves the tree as running it once does
##   ```sh classic     the classic counterpart; the next blocks must be ```sh and ```text, and both
##                     commands must print that text
##   ```sh bad         a wrong form (a pitfall), never run; the next blocks must be the fix and its
##                     ```text
##   ```sh unverified  not run (a tool that is not installed, interactive, or prints what differs
##                     per machine); allowed only on a page whose status line says why
##   ```text           the exact standard output of the command before it
## A command whose first line is `# exit: N` must end with status N; every other command with 0.

import std/[options, strutils]

type
  BlockKind* = enum
    bkRun, bkIdempotent, bkClassic, bkBad, bkUnverified, bkText, bkOther

  CodeBlock* = object
    kind*: BlockKind
    info*: string  ## the whole info string after the fence
    body*: string  ## the lines between the fences, each ending in "\n"
    line*: int     ## 1-based line of the opening fence

  Example* = object
    classic*: Option[CodeBlock]  ## the classic command that must print the same text
    command*: CodeBlock
    expected*: string
    exitCode*: int
    idempotent*: bool

  Section* = object
    heading*: string
    body*: string

  Page* = object
    title*: string
    status*: string  ## the reason after "Status: 未検証", or "" for a verified page
    sections*: seq[Section]
    blocks*: seq[CodeBlock]

  PageError* = object
    line*: int
    message*: string

  Examples* = object
    examples*: seq[Example]
    errors*: seq[PageError]

const
  requiredSections* = ["Intent", "Classic and modern", "Commands",
    "Differences that change results", "When to keep the classic command", "Pitfalls", "Sources"]
  statusPrefix = "Status: 未検証"
  exitPrefix = "# exit:"

func kindOf(info: string): BlockKind {.raises: [].} =
  let words = info.splitWhitespace
  if words.len == 0: return bkOther
  case words[0]
  of "text": bkText
  of "sh":
    if words.len == 1: bkRun
    else:
      case words[1]
      of "idempotent": bkIdempotent
      of "classic": bkClassic
      of "bad": bkBad
      of "unverified": bkUnverified
      else: bkOther
  else: bkOther

func parsePage*(text: string): Page {.raises: [].} =
  ## Title (the first `# ` line), status line, `## ` sections in order, and every fenced block.
  ## A fence is a line starting with ``` outside a block; the block ends at the next line that
  ## is exactly ```.
  var inBlock = false
  var current = CodeBlock()
  var lineNo = 0
  for raw in text.splitLines:
    inc lineNo
    if inBlock:
      if raw == "```":
        result.blocks.add current
        if result.sections.len > 0:
          result.sections[^1].body.add raw & "\n"
        inBlock = false
      else:
        current.body.add raw & "\n"
        if result.sections.len > 0:
          result.sections[^1].body.add raw & "\n"
      continue
    if raw.startsWith("```"):
      let info = raw[3 .. ^1].strip
      current = CodeBlock(kind: kindOf(info), info: info, body: "", line: lineNo)
      inBlock = true
      if result.sections.len > 0:
        result.sections[^1].body.add raw & "\n"
    elif raw.startsWith("## "):
      result.sections.add Section(heading: raw[3 .. ^1].strip, body: "")
    elif raw.startsWith("# ") and result.title.len == 0:
      result.title = raw[2 .. ^1].strip
    elif raw.startsWith(statusPrefix) and result.sections.len == 0:
      result.status = raw[statusPrefix.len .. ^1].strip(chars = {' ', '(', ')', ':'})
    elif result.sections.len > 0:
      result.sections[^1].body.add raw & "\n"

func expectedExit(body: string): Option[int] {.raises: [].} =
  ## N from a first line `# exit: N` (N in 0..255), 0 without that line, none when malformed.
  let first = (if body.len == 0: "" else: body.splitLines[0])
  if not first.startsWith(exitPrefix): return some(0)
  let digits = first[exitPrefix.len .. ^1].strip
  if digits.len == 0 or digits.len > 3: return none(int)
  var n = 0
  for c in digits:
    if c notin {'0'..'9'}: return none(int)
    n = n * 10 + (ord(c) - ord('0'))
  if n > 255: none(int) else: some(n)

func examplesOf*(page: Page): Examples {.raises: [].} =
  ## Pairs the blocks into examples, or says at which line the page breaks the block rules.
  let b = page.blocks
  var i = 0
  template fail(at: int; msg: string) =
    result.errors.add PageError(line: at, message: msg)

  func isCommand(k: BlockKind): bool = k in {bkRun, bkIdempotent}

  while i < b.len:
    let k = b[i].kind
    case k
    of bkRun, bkIdempotent:
      if page.status.len > 0:
        fail(b[i].line, "a page marked 未検証 has only ```sh unverified commands")
        i += (if i + 1 < b.len and b[i + 1].kind == bkText: 2 else: 1)
        continue
      if i + 1 >= b.len or b[i + 1].kind != bkText:
        fail(b[i].line, "```sh must be followed by its ```text output")
        inc i
        continue
      let code = expectedExit(b[i].body)
      if code.isNone:
        fail(b[i].line, "malformed `# exit: N` line (N in 0..255)")
      else:
        result.examples.add Example(classic: none(CodeBlock), command: b[i],
          expected: b[i + 1].body, exitCode: code.get, idempotent: k == bkIdempotent)
      i += 2
    of bkClassic, bkBad:
      let what = (if k == bkClassic: "```sh classic" else: "```sh bad")
      if i + 2 >= b.len or not isCommand(b[i + 1].kind) or b[i + 2].kind != bkText:
        fail(b[i].line, what & " must be followed by a ```sh command and its ```text output")
        inc i
        continue
      let code = expectedExit(b[i + 1].body)
      if code.isNone:
        fail(b[i + 1].line, "malformed `# exit: N` line (N in 0..255)")
      else:
        result.examples.add Example(
          classic: (if k == bkClassic: some(b[i]) else: none(CodeBlock)),
          command: b[i + 1], expected: b[i + 2].body, exitCode: code.get,
          idempotent: b[i + 1].kind == bkIdempotent)
      i += 3
    of bkUnverified:
      if page.status.len == 0:
        fail(b[i].line, "```sh unverified needs a status line `Status: 未検証 (<reason>)`")
      inc i
    of bkText:
      fail(b[i].line, "```text without a command before it")
      inc i
    of bkOther:
      inc i

func sectionOrderErrors*(page: Page): seq[string] {.raises: [].} =
  ## The required sections missing or out of order; empty when the page follows the shape.
  var at = 0
  for want in requiredSections:
    var found = -1
    for j in at ..< page.sections.len:
      if page.sections[j].heading == want:
        found = j
        break
    if found < 0: result.add "missing or out of order: ## " & want
    else: at = found + 1
