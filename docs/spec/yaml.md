# Spec table: yaml

One row per claim of the sections "Differences that change results" (D) and "When to keep the classic command" (K) of `skills/modern-cli/details/yaml.md`. 例 = an example of the page names the ID in a `# spec:` line; 本文のみ = no example does, for the category and reason given (MCLI-SPEC-02).

| ID | 箇所 | 主張 | 確かめ |
|---|---|---|---|
| CLI-YQ-01 | D1 | The output format follows the input (JSON in, JSON out with quotes) and `-o` and `-p` set it | 例 |
| CLI-YQ-02 | D2 | A missing key prints `null` and exits 0, and only `-e` exits 1 | 例 |
| CLI-YQ-03 | D3 | Scalar types are inferred, and a string that would change meaning is written with quotes | 例 |
| CLI-YQ-04 | D4 | Formatting is normalised on write: spacing before a trailing comment is reduced to one space | 例 |
| CLI-YQ-05 | D5 | `yq -i` rewrites the file, where BSD `sed -i` needs a suffix argument and GNU does not | 例 |
| CLI-YQ-06 | D6 | A file with `---` separators is processed per document, one result each | 例 |
| CLI-YQ-07 | D7 | `+=` and `\|= . + 1` change the file again on each run; assigning the final value with `unique` does not | 例 |
| CLI-YQ-08 | D8 | Filters look like jq's but are yq's own | 本文のみ (助言: advice about a dialect, nothing to assert) |
| CLI-YQ-09 | D9 | The examples were checked with yq v4.54.1 (mikefarah) | 本文のみ (版: the version is checked by MCLI-VER-01 in docs/tool-versions.md, not by an example) |
| CLI-YQ-10 | K1 | Keep `grep` and `sed` for one flat top-level key on a machine without yq | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-YQ-11 | K2 | Keep a one-line `sed` when every other byte of the file must stay as it is | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-YQ-12 | K3 | Keep other tools when the file is not YAML, since yq fails to parse it | 本文のみ (助言: advice on when to choose, not a result) |
