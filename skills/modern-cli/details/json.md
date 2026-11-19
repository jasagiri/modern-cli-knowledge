# Query and reshape JSON: jq

## Intent

Read, filter and reshape JSON with a real parser, so that quoting, nesting, escapes and number
formats cannot break the result the way a text pattern can.

## Classic and modern

| classic | modern |
|---|---|
| `grep -o '"version": *"[^"]*"' f.json \| sed 's/.*: *//'` | `jq '.version' f.json` |
| `python3 -m json.tool f.json` | `jq . f.json` |
| `grep -c '"name"' f.json` (count by text) | `jq 'length' f.json` / `jq 'map(select(...)) \| length'` |
| `sed 's/"debug": false/"debug": true/' f.json` | `jq '.debug = true' f.json` (to a new file) |

## Commands

Read one field. The classic pipeline has to know the exact spacing of the file and breaks when the
key moves, is nested, or the file is minified onto several lines. Both print the quoted string here:

```sh classic
grep -o '"version": *"[^"]*"' config/app.json | sed 's/.*: *//'
```
```sh
jq '.version' config/app.json
```
```text
"1.2.0"
```

Print the raw string, without the JSON quotes, with `-r`:

```sh
jq -r '.name, .version' config/app.json
```
```text
demo
1.2.0
```

Filter an array with `select` and print one field per line (`-r` for plain text):

```sh
jq -r '.[] | select(.team == "core") | .name' data/people.json
```
```text
Alice
Carol
```

Transform with `map`, and print on one line with `-c` (compact):

```sh
jq -c 'map(select(.age > 30)) | map(.name)' data/people.json
```
```text
["Alice","Carol"]
```

Pass a shell value into the filter with `--arg` (always a string; use `--argjson` for a number):

```sh
jq --arg t web -r '.[] | select(.team == $t) | .name' data/people.json
```
```text
Bob
```

Group and count. The result is a new document, not text cut out of the old one:

```sh
jq -c 'group_by(.team) | map({team: .[0].team, n: length})' data/people.json
```
```text
[{"team":"core","n":2},{"team":"web","n":1}]
```

Use the exit status with `-e`: it is 1 when the last output is `false` or `null`, and 4 when there
was no output at all:

```sh
jq -e '.debug' config/app.json > /dev/null; echo "false -> $?"; jq -e '.[] | select(.age > 99)' data/people.json > /dev/null; echo "no output -> $?"
```
```text
false -> 1
no output -> 4
```

A filter that does not compile exits 3, before any input is read:

```sh
# exit: 3
jq 'bad filter(' config/app.json
```
```text
```

## Differences that change results

- **Output is re-formatted.** `jq .` prints two-space indentation and one value per line;
  `python3 -m json.tool` indents by four spaces. Neither keeps the original layout, so a diff of a
  file against its `jq .` output shows formatting noise.
- **Strings keep their quotes.** `jq '.name'` prints `"demo"`; add `-r` for `demo`. A shell variable
  assigned from `jq` without `-r` contains the quotes.
- **Key order.** Objects print in the order of the input; `-S` sorts keys, which is what to use
  when two files must be compared.
- **Exit status.** By default jq exits 0 for `false`, `null` and no output; only `-e` maps them to
  1 and 4. Checked with `jq-1.7.1-apple`: 2 for an unreadable file or bad usage, 3 for a filter that does
  not compile (example below), 5 for invalid JSON input (from a file or standard input) and for an
  error while running the filter (`jq -n '1/0'`).
- **Comparison across types** follows a fixed order (null, false, true, numbers, strings, arrays,
  objects), so `.age > "30"` is never an error and never true for a number.
- **Editing.** jq has no in-place option: write to a temporary file and move it, or the file is
  emptied by `jq . f.json > f.json`.
- **Input is JSON only.** Comments, trailing commas and several concatenated documents that are not
  valid JSON make jq stop with a parse error; a text tool would not notice.
- **Version.** The examples were checked with `jq-1.7.1-apple`. Run `jq --version` on the machine
  where the command will run; this page does not cover other versions.

## When to keep the classic command

- A POSIX script or minimal image without jq: use `grep`/`sed` only for a flat, known file, and say
  in a comment that it is not a JSON parser.
- A one-off check that a file is valid JSON where Python is already installed:
  `python3 -m json.tool f.json > /dev/null` is enough.
- Line-oriented logs that are not one JSON document (each line a record) can be handled with
  `jq -c .` per line, but when only a substring is needed `grep` is simpler and faster.

## Pitfalls

`--arg` always makes a string, and a number compares as smaller than any string, so the filter
silently matches nothing:

```sh bad
jq --arg n 30 -c '.[] | select(.age > $n) | .name' data/people.json
```
```sh
jq --argjson n 30 -r '.[] | select(.age > $n) | .name' data/people.json
```
```text
Alice
Carol
```

## Sources

- `40610646b614d8d6` jq manual
- `0fcd5e4bf264865c` Data Science at the Command Line
