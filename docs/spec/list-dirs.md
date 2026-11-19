# Spec table: list-dirs

One row per claim of the sections "Differences that change results" (D) and "When to keep the classic command" (K) of `skills/modern-cli/details/list-dirs.md`. 例 = an example of the page names the ID in a `# spec:` line; 本文のみ = no example does, for the reason given (MCLI-SPEC-02).

| ID | 箇所 | 主張 | 確かめ |
|---|---|---|---|
| CLI-EZA-01 | D1 | eza sorts by name ignoring case by default; `--sort=Name` is the case-sensitive order of `ls` in the C locale, and `--sort=extension` and `-r` change it | 例 |
| CLI-EZA-02 | D2 | eza quotes names with spaces even when piped (`'meeting notes.txt'`) and `--no-quotes` gives plain names | 例 |
| CLI-EZA-03 | D3 | With no path and standard input that is not a terminal eza lists the paths read from it and prints nothing when there are none | 例 |
| CLI-EZA-04 | D4 | Piped, eza prints one name per line like `ls` | 例 |
| CLI-EZA-05 | D5 | `-a` includes dotfiles and no `.` and `..` | 例 |
| CLI-EZA-06 | D6 | eza lists ignored files unless `--git-ignore` is given, and then only in a real git repository | 例 |
| CLI-EZA-07 | D7 | eza marks directories with `/` only with `-F` (`--classify`), and a path right after `-F` is read as its value and is an error with status 2 | 例 |
| CLI-EZA-08 | D8 | The long format adds permissions, owner and dates that change; `--no-permissions --no-user --no-time` trims them | 例 |
| CLI-EZA-09 | D9 | `--tree` draws with box characters, prints the `.` root and no entry count | 例 |
| CLI-EZA-10 | D10 | The status is 0 on success and 2 for a missing path | 例 |
| CLI-EZA-11 | K1 | Keep `ls`, `find` or a shell glob in POSIX scripts, CI images and servers without eza | 本文のみ (advice on when to choose, not a result) |
| CLI-EZA-12 | K2 | Keep `ls` when a script parses the output and needs unquoted names, byte order or the exact `ls -l` columns | 本文のみ (advice on when to choose, not a result) |
| CLI-EZA-13 | K3 | Keep `fd` or `find -print0` for a list that is processed further, not read | 本文のみ (advice on when to choose, not a result) |
