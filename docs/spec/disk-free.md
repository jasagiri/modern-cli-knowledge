# Spec table: disk-free

One row per claim of the sections "Differences that change results" (D) and "When to keep the classic command" (K) of `skills/modern-cli/details/disk-free.md`. 例 = an example of the page names the ID in a `# spec:` line; 本文のみ = no example does, for the category and reason given (MCLI-SPEC-02).

| ID | 箇所 | 主張 | 確かめ |
|---|---|---|---|
| CLI-DUF-01 | D1 | The tool groups are local, network, fuse, special, loops and binds, and `-all` also includes pseudo, duplicate and inaccessible filesystems | 例 |
| CLI-DUF-02 | D1 | By default duf shows local, network, fuse and special groups, so a mount that `df` shows may be missing | 本文のみ (機械: the mounts and their counts depend on the machine) |
| CLI-DUF-03 | D2 | The table is split into groups; scripts use `-json` (all devices, filter with `jq`) or `-output` | 例 |
| CLI-DUF-04 | D3 | duf shows human-readable sizes where BSD `df` shows 512-byte blocks unless `-h` or `-k` | 本文のみ (機械: sizes depend on the machine) |
| CLI-DUF-05 | D4 | Flags must come before the paths: `duf -json /tmp` works and `duf /tmp -json` reads `-json` as a path and fails with an `lstat` error | 例 |
| CLI-DUF-06 | D5 | BSD and GNU `df` differ in columns and flags while duf prints the same table on both | 本文のみ (機械: no GNU df on the checking machine) |
| CLI-DUF-07 | K1 | Keep `df -P` in POSIX scripts, containers and servers without duf | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-DUF-08 | K2 | Keep `df -Pk` when a script parses the output | 本文のみ (助言: advice on when to choose, not a result) |
