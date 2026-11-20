# Spec table: disk-usage

One row per claim of the sections "Differences that change results" (D) and "When to keep the classic command" (K) of `skills/modern-cli/details/disk-usage.md`. 例 = an example of the page names the ID in a `# spec:` line; 本文のみ = no example does, for the category and reason given (MCLI-SPEC-02).

| ID | 箇所 | 主張 | 確かめ |
|---|---|---|---|
| CLI-DUST-01 | D1 | `dust -s` reports the length of each file, which is the same on every machine | 例 |
| CLI-DUST-02 | D1 | Without `-s` dust and `du` report blocks allocated on disk, so a 12-byte file shows as 4 KiB or whatever the filesystem allocates | 本文のみ (機械: block sizes depend on the filesystem of the machine) |
| CLI-DUST-03 | D2 | A directory row includes the space of its own entry, so it is not the sum of its files; with `-e` or `-v` the sum is exact | 例 |
| CLI-DUST-04 | D3 | dust prints smallest first and `-r` biggest first, where `du` prints in walk order | 例 |
| CLI-DUST-05 | D4 | `-n` limits the rows to the largest n and `-z` to those of at least a size | 例 |
| CLI-DUST-06 | D4 | Without `-n` dust shows only the rows that fit the terminal height | 本文のみ (端末: the terminal height is not available to an example) |
| CLI-DUST-07 | D5 | dust prints human units in powers of 1024, `-o si` powers of 1000, and BSD `du` uses 512-byte blocks unless `-k`, `-h` or `BLOCKSIZE` | 例 |
| CLI-DUST-08 | D6 | Bars and a progress line appear on a terminal and `-b` and `-P` remove them | 例 |
| CLI-DUST-09 | D7 | dust counts hidden files (`-i` skips them) and does not read `.gitignore` | 例 |
| CLI-DUST-10 | D8 | The status is 0 when at least one path could be read and 1 when none could, while `du` exits 1 as soon as any path fails | 例 |
| CLI-DUST-11 | K1 | Keep `du -k` or `du -sk` in POSIX scripts, CI images and servers without dust | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-DUST-12 | K2 | Keep `du -sk DIR \| cut -f1` when a script needs one number per path | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-DUST-13 | K3 | Keep `du` when an exact disk-usage figure per directory should match `df` | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-DUST-14 | K2 | `wc -c < FILE` gives a file's exact length, which BSD `wc` pads with spaces | 例 |
