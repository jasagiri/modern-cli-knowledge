# Read and edit YAML: yq

## Intent

Read and change values in YAML (and convert between YAML and JSON) by path, keeping the document
valid, instead of cutting lines out of it with text patterns.

This page is about `yq` by mikefarah (version 4). Another program may be installed under the same
name: check `yq --version` shows `https://github.com/mikefarah/yq`.

## Classic and modern

| classic | modern |
|---|---|
| `grep '^version:' f.yaml \| sed 's/^version: *//'` | `yq '.version' f.yaml` |
| `sed -i '' 's/^debug: false/debug: true/' f.yaml` (BSD; GNU: `sed -i`) | `yq -i '.debug = true' f.yaml` |
| `python3 -c 'import yaml,json,sys; print(json.dumps(yaml.safe_load(sys.stdin)))' < f.yaml` | `yq -o=json -I=0 '.' f.yaml` |
| (no POSIX tool converts JSON to YAML; a script in another language is the classic route) | `yq -p=json -o=yaml '.' f.json` |

## Commands

Read one value. The classic pipeline depends on the key being at the top level, unquoted and on one
line; the path expression does not:

```sh classic
grep '^version:' config/app.yaml | sed 's/^version: *//'
```
```sh
yq '.version' config/app.yaml
```
```text
1.2.0
```

Read a list, one element per line, and its length:

```sh
yq '.ports[]' config/app.yaml; yq '.ports | length' config/app.yaml
```
```text
8080
8443
2
```

Edit in place. Both commands leave the same file here, but the BSD `sed -i` needs the empty
backup-suffix argument `''` (GNU `sed -i` must not have it) and only works while the line has this
exact shape:

```sh classic
sed -i '' 's/^debug: false/debug: true/' config/app.yaml && cat config/app.yaml
```
```sh
# spec: CLI-YQ-05
yq -i '.debug = true' config/app.yaml && cat config/app.yaml
```
```text
name: demo
version: 1.2.0
debug: true
ports:
  - 8080
  - 8443
```

Adding to a list so that running the command twice gives the same file: build the new list with
`unique`, because `+=` appends again every time:

```sh idempotent
# spec: CLI-YQ-07
yq -i '.ports = (.ports + [9090] | unique)' config/app.yaml && cat config/app.yaml
```
```text
name: demo
version: 1.2.0
debug: false
ports:
  - 8080
  - 8443
  - 9090
```

Convert YAML to compact JSON, and JSON to YAML:

```sh
# spec: CLI-YQ-01
yq -o=json -I=0 '.' config/app.yaml; yq -p=json -o=yaml '.' config/app.json
```
```text
{"name":"demo","version":"1.2.0","debug":false,"ports":[8080,8443]}
name: demo
version: 1.2.0
debug: false
ports:
  - 8080
  - 8443
```

Delete a key (printed, the file is not changed without `-i`):

```sh
yq 'del(.debug)' config/app.yaml
```
```text
name: demo
version: 1.2.0
ports:
  - 8080
  - 8443
```

The output format follows the input: JSON in gives JSON out, with quotes. A missing key prints
`null` and exits 0:

```sh
# spec: CLI-YQ-01 CLI-YQ-02
yq '.name' config/app.json
yq '.name' config/app.yaml
yq '.nope' config/app.yaml; echo "status: $?"
```
```text
"demo"
demo
null
status: 0
```

A string assigned to a key is written with quotes, because `3` would otherwise be read as a number.
Spacing before a trailing comment is reduced to one space, and a file with several documents gives
one result per document, separated by `---`:

```sh
# spec: CLI-YQ-03 CLI-YQ-04 CLI-YQ-06
yq '.version = "3"' config/app.yaml | head -2
printf 'a:   1    # c\n' | yq .
printf 'a: 1\n---\na: 2\n' | yq '.a'
```
```text
name: demo
version: "3"
a: 1 # c
1
---
2
```

`-e` turns a missing key into a failure, which a script can test:

```sh
# spec: CLI-YQ-02
# exit: 1
yq -e '.nope' config/app.yaml
```
```text
null
```

To compare a value across a JSON and a YAML file, print both as compact JSON and compare the strings
(list order counts; add `-S` to jq and `sort_keys(..)` to yq when key order should not):

```sh
[ "$(jq -c '.ports' config/app.json)" = "$(yq -o=json -I=0 '.ports' config/app.yaml)" ] && echo agree
```
```text
agree
```

## Differences that change results

- **Output format follows the input.** `yq '.name' config/app.json` prints `"demo"` (JSON in, JSON
  out, with quotes); the same filter on the YAML file prints `demo`. Set it with `-o=yaml|json|props`
  and `-p=` for the input.
- **Missing keys.** `yq '.nope' f.yaml` prints `null` and exits 0; only `-e` exits 1 (it still prints
  `null`, and writes `Error: no matches found` to standard error). `grep` exits 1 when a
  line is missing, which is a different question.
- **Scalar types are inferred.** `1.10` is a float and `true` a bool unless quoted; a filter that
  assigns a string writes quotes when the value would otherwise change meaning
  (`yq '.version = "3"'` writes `version: "3"`). Check with `yq '.v | tag'`.
- **Formatting is normalised on write.** Comments are kept, but spacing before a trailing comment is
  reduced to one space and quoting style may change; a diff after `-i` can be larger than the edit.
- **In-place editing.** `yq -i` rewrites the file; BSD `sed -i` needs a suffix argument (`''`) and
  GNU does not, so a copied command fails on the other system. Neither keeps a backup unless asked.
- **Multiple documents.** A file with `---` separators is processed per document; `yq '.a' f.yaml`
  prints one result per document, separated by `---`.
- **Not idempotent by default.** `+=`, `|= . + 1` and similar change the file again on each run.
  Write the edit as an assignment of the final value, or guard it with `unique` or `select`.
- **Dialect.** Filters look like jq's but are yq's own; run a filter before reusing a jq recipe.
- **Version.** The examples were checked with `yq v4.54.1` (mikefarah); other versions and other
  programs named `yq` are not covered.

## When to keep the classic command

- A POSIX script on a machine without yq: for one flat top-level key `grep`/`sed` is enough, but
  say in a comment that it is not a YAML parser.
- A byte-exact change where the rest of the file must not be reformatted at all: a one-line `sed`
  keeps every other byte, while `yq -i` may re-indent or re-quote.
- When the file is not YAML (for example a template with `{{ }}` blocks): yq fails to parse it.

## Pitfalls

`+=` appends on every run, so a setup script run twice puts the value in the list twice:

```sh bad
yq -i '.ports += [9090]' config/app.yaml
```
```sh idempotent
# spec: CLI-YQ-07
yq -i '.ports = (.ports + [9090] | unique)' config/app.yaml && yq -o=json -I=0 '.ports' config/app.yaml
```
```text
[8080,8443,9090]
```

## Sources

- `f1aadf3f99260746` yq documentation
