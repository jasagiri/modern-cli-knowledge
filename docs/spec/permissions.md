# Spec table: permissions

One row per claim of the sections "Differences that change results" (D) and "When to keep the classic command" (K) of `skills/modern-cli/details/permissions.md`. 例 = an example of the page names the ID in a `# spec:` line; 本文のみ = no example does, for the category and reason given (MCLI-SPEC-02).

| ID | 箇所 | 主張 | 確かめ |
|---|---|---|---|
| CLI-PERM-01 | D1 | Octal sets all nine bits, symbolic `+`, `-` adjust and `=` resets the named triples | 例 |
| CLI-PERM-02 | D2 | A directory needs `x` to reach what is inside, `w` to create entries and `r` only to list names | 例 |
| CLI-PERM-03 | D3 | A read-only file can be removed from a writable directory, and a writable file cannot be removed from a read-only one | 例 |
| CLI-PERM-04 | D4 | `chmod -R a+X` makes directories enterable and leaves plain files alone, `go-rwx` removes exactly | 例 |
| CLI-PERM-05 | D5 | `umask` removes bits only from new files and directories, files never start executable, and `chmod` with a who letter is not limited by it | 例 |
| CLI-PERM-06 | D4 | A script without `x` fails with status 126 when started by path | 例 |
| CLI-PERM-07 | D6 | The fourth octal digit sets setuid, setgid and sticky, shown as `s` and `t`; `install -m` and `mkdir -m` set a mode on creation | 例 |
| CLI-PERM-08 | D7 | A user may `chown` a file they own to themselves | 例 |
| CLI-PERM-09 | D4 | `chmod -R` follows no symlink by default, `-H`, `-L` and `-P` choose | 本文のみ (機械: not run, the example tree has no symlink case) |
| CLI-PERM-10 | D6 | `stat -f %Lp` (BSD) does not print the special bits and `%Sp` prints the string | 本文のみ (機械: `stat -f` exists on BSD only) |
| CLI-PERM-11 | D7 | A normal user cannot `chown` to someone else and `chgrp` only accepts a group the user belongs to | 本文のみ (機械: needs another user or group) |
| CLI-PERM-12 | D9 | `chmod --reference`, `chown --reference` and the long options are GNU only, `stat -c %a` is GNU and `stat -f %Lp` BSD | 本文のみ (機械: no GNU chmod or stat on the checking machine) |
| CLI-PERM-13 | D9 | macOS has ACLs and flags that the ten characters of `ls -l` do not show | 本文のみ (機械: depends on the OS) |
| CLI-PERM-14 | K1 | In a POSIX script use octal or the POSIX symbolic forms and `ls -ld` to read a mode | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-PERM-15 | K2 | Use `install -m` or `mkdir -m` to set a mode on creation | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-PERM-16 | K3 | Read permissions in a listing with `ls -l` or `eza -l`, which a script should not parse | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-PERM-17 | K4 | List executable files with `fd -t x` | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-PERM-18 | D8 | An invalid mode exits 1 and changes nothing | 例 |
