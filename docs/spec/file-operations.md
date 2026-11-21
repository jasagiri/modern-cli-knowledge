# Spec table: file-operations

One row per claim of the sections "Differences that change results" (D) and "When to keep the classic command" (K) of `skills/modern-cli/details/file-operations.md`. 例 = an example of the page names the ID in a `# spec:` line; 本文のみ = no example does, for the category and reason given (MCLI-SPEC-02).

| ID | 箇所 | 主張 | 確かめ |
|---|---|---|---|
| CLI-FILE-01 | D1 | BSD `cp -R s/ t` copies the contents of `s` into `t`, and `cp -R s t` copies `s` itself (into `t/s` when `t` exists) | 例 |
| CLI-FILE-02 | D2 | `cp` and `mv` overwrite silently; `-n` skips (BSD `cp -n` exits 1, `mv -n` exits 0) and `-i` asks | 例 |
| CLI-FILE-03 | D3 | `cp -p` keeps the modification time where plain `cp` does not; `-R` copies a symlink as a link and `-L` follows it | 例 |
| CLI-FILE-04 | D4 | `mkdir -p` creates missing parents and succeeds on an existing directory; without `-p` it fails with status 1 | 例 |
| CLI-FILE-05 | D5 | `rm` needs `-r` for a directory, `-f` hides a missing file, `-i` asks, a name with a leading `-` needs `--` | 例 |
| CLI-FILE-06 | D6 | `${dir:?}` makes the shell stop with a non-zero status when `dir` is empty, so `rm` does not run | 例 |
| CLI-FILE-07 | D7 | A relative symlink target is read from the link's directory, so moving the link leaves it dangling | 例 |
| CLI-FILE-08 | D8 | A hard link is a second name for the same content | 例 |
| CLI-FILE-09 | D9 | `touch` creates an empty file, only updates the times of an existing one, `-c` creates nothing | 例 |
| CLI-FILE-10 | D10 | `mv a b` renames, or moves into `b` when `b` is a directory | 例 |
| CLI-FILE-11 | D1 | GNU `cp -R s/ t` treats the slash like `s`, and `cp -R s/. t/` copies the contents on both | 本文のみ (機械: no GNU cp on the checking machine) |
| CLI-FILE-12 | D2 | GNU `cp -n` and `mv -n` have changed their exit status between versions | 本文のみ (機械: no GNU cp or mv on the checking machine) |
| CLI-FILE-13 | D9 | BSD `touch -t` takes `[[CC]YY]MMDDhhmm[.SS]` and GNU `touch -d` accepts free-form dates that BSD does not | 本文のみ (機械: no GNU touch on the checking machine) |
| CLI-FILE-14 | D10 | `mv -T` and `mv -t DIR` are GNU only | 本文のみ (機械: no GNU mv on the checking machine) |
| CLI-FILE-15 | K1 | In a POSIX script use only the POSIX options of the six tools | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-FILE-16 | K2 | Select files with `fd` and pass them on instead of a glob in `rm` | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-FILE-17 | K3 | Use `rsync` to copy a tree repeatedly or to a remote machine | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-FILE-18 | K4 | Commit a state first, since `rm` and an overwriting `cp` or `mv` have no undo | 本文のみ (助言: advice on when to choose, not a result) |
