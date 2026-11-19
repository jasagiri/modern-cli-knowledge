# Spec table: combine

One row per claim of the sections "Differences that change results" (D) and "When to keep the classic command" (K) of `skills/modern-cli/details/combine.md`. 例 = an example of the page names the ID in a `# spec:` line; 本文のみ = no example does, for the reason given (MCLI-SPEC-02).

| ID | 箇所 | 主張 | 確かめ |
|---|---|---|---|
| CLI-COMBINE-01 | D1 | `fd`, `rg -l` and `fzf` end lines with `\n`, so a name with a space splits in `xargs`; `-0`/`--null`/`-l0` with `xargs -0` and `sort -z` keep it whole | 例 |
| CLI-COMBINE-02 | D2 | Without a path argument `fd` prints `./` paths with `-0`, `-x` and `-X` but not when piped | 例 |
| CLI-COMBINE-03 | D3 | `fd -x` runs jobs in parallel and `rg` needs `--sort path`, so the final output must be sorted | 本文のみ (the order of parallel jobs is not deterministic, so no example can show it; the examples sort) |
| CLI-COMBINE-04 | D4 | `-x` runs the command once per file and `-X` once with all files (`wc -l` prints a total) | 例 |
| CLI-COMBINE-05 | D5 | `fd` and `rg` skip ignored and hidden files while `find` and `grep -r` do not | 例 |
| CLI-COMBINE-06 | D6 | `sd` edits the file in place and prints nothing; `sed -i ''` is BSD and `sed -i` is GNU | 例 |
| CLI-COMBINE-07 | D7 | A pipeline reports the status of its last command, so a missing match is hidden | 例 |
| CLI-COMBINE-08 | D8 | `sd` uses Rust regex with `$1` captures where `sed` uses `\1` | 例 |
| CLI-COMBINE-09 | K1 | Keep `find`, `xargs` and `sed` in POSIX scripts and on servers without fd, rg and sd | 本文のみ (advice on when to choose, not a result) |
| CLI-COMBINE-10 | K2 | Keep `find ... -print0` when every file, ignored and hidden ones too, must be touched | 本文のみ (advice on when to choose, not a result) |
| CLI-COMBINE-11 | K3 | Keep `find -exec ... +` when a script must run unchanged on Linux and macOS, and branch on the output rather than the status | 例 |
| CLI-COMBINE-12 | K4 | Keep `sd A B file` for a one-file edit that needs no pipeline | 本文のみ (advice on when to choose, not a result) |
