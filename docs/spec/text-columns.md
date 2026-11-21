# Spec table: text-columns

One row per claim of the sections "Differences that change results" (D) and "When to keep the classic command" (K) of `skills/modern-cli/details/text-columns.md`. 例 = an example of the page names the ID in a `# spec:` line; 本文のみ = no example does, for the category and reason given (MCLI-SPEC-02).

| ID | 箇所 | 主張 | 確かめ |
|---|---|---|---|
| CLI-TEXT-01 | D1 | Without `-n`, `sort` puts `10` before `9`, and in `C.UTF-8` capital letters before small ones; `-f` ignores case | 例 |
| CLI-TEXT-02 | D2 | Lines with an equal key are ordered by the whole line unless `-s` keeps the input order; `-u` keeps one line per run | 例 |
| CLI-TEXT-03 | D3 | `uniq` removes only adjacent duplicates, `sort -u` deduplicates, `sort \| uniq -c` counts | 例 |
| CLI-TEXT-04 | D4 | `cut` takes a single-character delimiter, repeated spaces give empty fields, a line without the delimiter is printed whole unless `-s`; `awk` treats a run of blanks as one separator | 例 |
| CLI-TEXT-05 | D5 | `cut -c` follows the locale, `cut -b` counts bytes | 例 |
| CLI-TEXT-06 | D6 | `tr` reads standard input only and works on characters and ranges | 例 |
| CLI-TEXT-07 | D7 | `awk` fields, `-F`, `-v`, `NF` and `END` | 例 |
| CLI-TEXT-08 | D8 | BSD `wc` pads its numbers, `-l` counts newline characters, `-m` characters and `-c` bytes | 例 |
| CLI-TEXT-09 | D9 | `tail -n +K` starts at line K; `head -n -K` fails on BSD with `illegal line count` | 例 |
| CLI-TEXT-10 | D10 | `comm` and `join` need input sorted by the same rule and give a wrong result without an error otherwise | 例 |
| CLI-TEXT-11 | D11 | `nl` numbers non-empty lines only, `-ba` all of them | 例 |
| CLI-TEXT-12 | D11 | `paste` joins lines with a tab, `paste - -` takes two lines at a time, `-s` and `-d` | 例 |
| CLI-TEXT-13 | D1 | In a locale such as `en_US.UTF-8` the order differs from `C`; `LC_ALL=C sort` makes two machines agree | 本文のみ (機械: the fixed locale of the example is C.UTF-8) |
| CLI-TEXT-14 | D3 | BSD `uniq -c` pads the count to 4 columns and GNU to 7 | 本文のみ (機械: no GNU uniq on the checking machine) |
| CLI-TEXT-15 | D5 | `awk` `length` counts bytes in the macOS awk (version 20200816) and characters in `gawk` in a UTF-8 locale | 本文のみ (機械: no gawk on the checking machine) |
| CLI-TEXT-16 | D7 | `gensub`, `asort` and `--version` are `gawk` features and fail on the macOS `awk` | 本文のみ (機械: no gawk on the checking machine) |
| CLI-TEXT-17 | D8 | GNU `wc` does not pad when reading standard input | 本文のみ (機械: no GNU wc on the checking machine) |
| CLI-TEXT-18 | D9 | `sed '$d'` is the portable way to drop the last line, where `head -n -K` is GNU only | 例 |
| CLI-TEXT-19 | D10 | GNU `join` has `--check-order` | 本文のみ (機械: no GNU join on the checking machine) |
| CLI-TEXT-20 | K1 | Keep the POSIX options of the twelve tools in scripts, CI images and servers | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-TEXT-21 | K2 | Use `jq` or `yq`, not `cut` or `awk`, for JSON and YAML | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-TEXT-22 | K3 | Use `rg` rather than `awk '/re/'` or `grep \| cut` to search files | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-TEXT-23 | K4 | Use `fd` and `dust` to count files, which know what to skip, rather than `wc -l *` | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-TEXT-24 | K5 | Use a CSV-aware tool for CSV with quoted fields | 本文のみ (助言: advice on when to choose, not a result) |
