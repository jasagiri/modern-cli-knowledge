# Spec table: replace-text

One row per claim of the sections "Differences that change results" (D) and "When to keep the classic command" (K) of `skills/modern-cli/details/replace-text.md`. 例 = an example of the page names the ID in a `# spec:` line; 本文のみ = no example does, for the reason given (MCLI-SPEC-02).

| ID | 箇所 | 主張 | 確かめ |
|---|---|---|---|
| CLI-SD-01 | D1 | `sd OLD NEW FILE` overwrites the file with no backup and no `-i`, `-p` previews, and with no file sd reads standard input | 例 |
| CLI-SD-02 | D2 | BSD `sed -i` takes the next argument as the backup suffix, so the GNU form `sed -i 's/a/b/' f` fails on macOS; sd has no such difference | 例 |
| CLI-SD-03 | D2 | GNU `sed -i` takes an optional attached suffix and `sed -i ''` fails on GNU | 本文のみ (no GNU sed on the checking machine) |
| CLI-SD-04 | D3 | sed replaces the first match per line unless `g`, sd replaces all and `-n N` limits the total | 例 |
| CLI-SD-05 | D4 | sd uses Rust regex (`\d`, `\w`, groups without backslash, no backreference in the pattern) where BSD `sed` uses basic regex | 例 |
| CLI-SD-06 | D5 | Groups are `$1`, `${1}` or `$name`; `$1USD` is ambiguous (status 1) and `${1}USD` works; a literal `$` is `$$` | 例 |
| CLI-SD-07 | D6 | sd works line by line so `\n` never matches, and `-A` reads each input as a whole | 例 |
| CLI-SD-08 | D7 | sd has no delimiter, so a `/` needs no escaping | 例 |
| CLI-SD-09 | D8 | No match exits 0 and leaves the input unchanged, and an invalid regex exits 1 | 例 |
| CLI-SD-10 | D9 | A pattern that starts with `-` needs `--` before it | 例 |
| CLI-SD-11 | K1 | Keep `sed` (and `sed -i.bak`, which works on BSD and GNU) in POSIX scripts on machines without sd | 本文のみ (advice on when to choose, not a result) |
| CLI-SD-12 | K2 | Keep `sed` for line-oriented edits such as `sed -n '5,10p'`, `sed '/pat/d'` and inserting a line with a backslash and a newline | 例 |
| CLI-SD-13 | K3 | Keep `sed` when the script relies on basic-regex semantics or `\1` in the replacement | 本文のみ (advice on when to choose, not a result) |
