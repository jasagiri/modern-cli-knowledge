# Spec table: view-files

One row per claim of the sections "Differences that change results" (D) and "When to keep the classic command" (K) of `skills/modern-cli/details/view-files.md`. 例 = an example of the page names the ID in a `# spec:` line; 本文のみ = no example does, for the reason given (MCLI-SPEC-02).

| ID | 箇所 | 主張 | 確かめ |
|---|---|---|---|
| CLI-BAT-01 | D1 | On a terminal bat adds a header, grid, numbers, colour and a pager; piped it prints the file unchanged, and `-p` and `-n` ask for plain and numbers explicitly | 例 |
| CLI-BAT-02 | D2 | Style options are ignored when piped unless `--decorations=always`: `--style=numbers` prints no numbers and `-n` does | 例 |
| CLI-BAT-03 | D3 | On a terminal output longer than the screen opens `less`, so a waiting script hangs unless `-p -p`, `--paging=never` or `BAT_PAGER=` is used | 本文のみ (a pager needs a terminal) |
| CLI-BAT-04 | D4 | `cat` joins several files with no marker, bat on a terminal prints a header per file and piped none | 例 |
| CLI-BAT-05 | D5 | `cat` prints binary bytes and bat refuses to print binary content to a terminal unless `--binary=as-text` | 本文のみ (the refusal happens on a terminal only) |
| CLI-BAT-06 | D6 | Line ranges and numbers exist only in bat, and `cat -n` uses a tab after the number where `bat -n` uses a space | 例 |
| CLI-BAT-07 | D7 | The status is 0 when all files were printed and 1 when any could not be read | 例 |
| CLI-BAT-08 | D8 | Syntax detection uses the file name and first line, and a wrong guess only changes colour | 本文のみ (colour is not shown in a pipe) |
| CLI-BAT-09 | K1 | Keep `cat` in POSIX scripts, CI images and servers without bat | 本文のみ (advice on when to choose, not a result) |
| CLI-BAT-10 | K2 | Keep `cat` when concatenating files into a file or pipe where decoration would corrupt the data | 本文のみ (advice on when to choose, not a result) |
| CLI-BAT-11 | K3 | Keep `sed -n` or `head`/`tail` for lines from the middle of a stream that is not a file | 本文のみ (advice on when to choose, not a result) |
| CLI-BAT-12 | K4 | Keep `cat` when the exact bytes matter (binary data, `\r`, no trailing newline) | 本文のみ (advice on when to choose, not a result) |
