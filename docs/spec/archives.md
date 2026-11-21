# Spec table: archives

One row per claim of the sections "Differences that change results" (D) and "When to keep the classic command" (K) of `skills/modern-cli/details/archives.md`. 例 = an example of the page names the ID in a `# spec:` line; 本文のみ = no example does, for the category and reason given (MCLI-SPEC-02).

| ID | 箇所 | 主張 | 確かめ |
|---|---|---|---|
| CLI-TAR-01 | D1 | The `tar` of macOS is `bsdtar` | 例 |
| CLI-TAR-02 | D2 | `tar -cf a.tar notes` unpacks as `notes/...` and `-C notes .` stores its files without the directory | 例 |
| CLI-TAR-03 | D3 | A leading `/` is removed on creation, so `/etc/hosts` unpacks as `etc/hosts` | 例 |
| CLI-TAR-04 | D5 | `-z`, `-j` and `-J` select the compressor when creating and reading needs no flag; a pipe through `gzip` makes the same archive | 例 |
| CLI-TAR-05 | D9 | A missing member gives status 1 and the extraction of the other members is not undone | 例 |
| CLI-TAR-06 | D6 | Extraction replaces existing files without asking, `-k` keeps them | 例 |
| CLI-TAR-07 | D7 | `tar -t` prints the members in the stored order, which follows the directory order of the filesystem | 本文のみ (非決定: the order depends on the filesystem) |
| CLI-TAR-08 | D8 | bsdtar writes the `-v` list to standard error | 例 |
| CLI-TAR-09 | D4 | `-C` applies to the names after it, and with `-x` fails with status 1 when the directory does not exist | 例 |
| CLI-TAR-10 | D1 | GNU tar and bsdtar accept different long options, so only the shared options are portable | 本文のみ (機械: no GNU tar on the checking machine) |
| CLI-TAR-11 | D5 | GNU tar's `-z` on input that is not gzip fails where bsdtar's succeeds | 本文のみ (機械: no GNU tar on the checking machine) |
| CLI-TAR-12 | D8 | GNU tar writes the `-v` list to standard output when creating | 本文のみ (機械: no GNU tar on the checking machine) |
| CLI-TAR-13 | K1 | In a POSIX script use `tar -cf - DIR \| gzip` and `gzip -dc \| tar -xf -` instead of `-z` | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-TAR-14 | K2 | Use `zip` and `unzip` for `.zip` files | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-TAR-15 | K3 | Use `gzip -k` for one file, no archive is needed | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-TAR-16 | K4 | Use `rsync` to copy a tree repeatedly or over a network, and `jj` to keep versions | 本文のみ (助言: advice on when to choose, not a result) |
