# Spec table: json

One row per claim of the sections "Differences that change results" (D) and "When to keep the classic command" (K) of `skills/modern-cli/details/json.md`. 例 = an example of the page names the ID in a `# spec:` line; 本文のみ = no example does, for the reason given (MCLI-SPEC-02).

| ID | 箇所 | 主張 | 確かめ |
|---|---|---|---|
| CLI-JQ-01 | D1 | `jq .` prints two-space indentation and one value per line, not the original layout | 例 |
| CLI-JQ-02 | D2 | Strings keep their quotes unless `-r` is given | 例 |
| CLI-JQ-03 | D3 | Objects print in the input order and `-S` sorts the keys | 例 |
| CLI-JQ-04 | D4 | By default jq exits 0 for `false`, `null` and no output; `-e` maps them to 1 and 4; 2, 3 and 5 report an unreadable file, a filter that does not compile and invalid JSON or a runtime error | 例 |
| CLI-JQ-05 | D5 | Comparison across types follows a fixed order, so a number is never greater than a string and no comparison is an error | 例 |
| CLI-JQ-06 | D6 | jq has no in-place option, and `jq . f.json > f.json` empties the file | 例 |
| CLI-JQ-07 | D7 | Input is JSON only: a trailing comma or concatenated non-JSON documents stop jq with a parse error | 例 |
| CLI-JQ-08 | D8 | The examples were checked with `jq-1.7.1-apple` | 本文のみ (the version is checked by MCLI-VER-01 in docs/tool-versions.md, not by an example) |
| CLI-JQ-09 | K1 | Keep `grep` and `sed` only for a flat, known file in a POSIX script or image without jq | 本文のみ (advice on when to choose, not a result) |
| CLI-JQ-10 | K2 | Keep `python3 -m json.tool f.json > /dev/null` for a one-off validity check where Python is installed | 本文のみ (advice on when to choose, not a result) |
| CLI-JQ-11 | K3 | Keep `grep` for line-oriented logs when only a substring is needed | 本文のみ (advice on when to choose, not a result) |
