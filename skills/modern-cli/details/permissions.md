# Set file permissions and ownership: chmod, chown, chgrp, umask

## Intent

Read and change who may read, write and execute a file with `chmod`, change its owner and group
with `chown` and `chgrp` where that is allowed, and know what `umask` does to files that a command
creates.

## Classic and modern

| classic | modern |
|---|---|
| `chmod`, `chown`, `chgrp`, `umask` | none (keep the classic tool) |

## Commands

The mode of a file is shown by the first ten characters of `ls -l` (`cut -c1-10` drops the owner,
the size and the date, and the `@` that macOS adds for extended attributes). The ten characters are
the type (`-` file, `d` directory, `l` link) and three triples of `r`, `w`, `x` for the owner, the
group and the others. In octal, `r` is 4, `w` is 2 and `x` is 1 and a digit is their sum: `640` is
`rw-` `r--` `---`. A symbolic mode says who (`u` `g` `o` `a`), then `+` (add), `-` (remove) or
`=` (set exactly), then the permissions:

```sh
# spec: CLI-PERM-01
touch f
chmod 640 f; ls -l f | cut -c1-10
chmod g+w,o+r f; ls -l f | cut -c1-10
chmod u+x,g-r f; ls -l f | cut -c1-10
chmod a=r f; ls -l f | cut -c1-10
chmod 'u=rw,go=' f; ls -l f | cut -c1-10
```
```text
-rw-r-----
-rw-rw-r--
-rwx-w-r--
-r--r--r--
-rw-------
```

On a directory `r` lists the names, `w` creates and removes entries, and `x` allows going through
it to a name inside (`cd`, or opening `d/sub/f`). They are separate: with `r` and no `x` the names
are listed but nothing inside can be opened, with `x` and no `r` a file can be opened by its exact
name but `ls` fails, and with `r` and `x` but no `w` nothing can be created:

```sh
# spec: CLI-PERM-02
mkdir -p d/sub; echo hi > d/sub/f
chmod 600 d
ls d; cat d/sub/f 2>/dev/null; echo "cat: $?"
chmod 311 d
ls d 2>/dev/null; echo "ls: $?"; cat d/sub/f
chmod 500 d
touch d/new 2>/dev/null; echo "touch: $?"
chmod 700 d
```
```text
sub
cat: 1
ls: 1
hi
touch: 1
```

Whether a file may be deleted depends on the directory, not on the file: `rm` of a read-only file
works when the directory is writable, and fails in a directory without `w`. Writing to the
read-only file itself fails:

```sh
# spec: CLI-PERM-03
touch f; chmod 444 f
(echo y > f) 2>/dev/null; echo "write: $?"
rm f; echo "rm: $?"
mkdir d; touch d/g; chmod 555 d
rm d/g 2>/dev/null; echo "rm in d: $?"
chmod 755 d
```
```text
write: 1
rm: 0
rm in d: 1
```

`-R` changes a whole tree. `go-rwx` is an exact removal. The capital `X` in `a+X` adds `x` only to
directories and to files that already have an `x` for someone, so a tree of plain files stays
non-executable while its directories can be entered (`a+X` adds only `x`, so the read bits that
`go-rwx` removed stay removed):

```sh
# spec: CLI-PERM-04
mkdir -p d/e; touch d/e/f d/g
chmod -R go-rwx d
ls -ld d d/e d/e/f d/g | cut -c1-10
chmod -R a+X d
ls -ld d d/e d/e/f d/g | cut -c1-10
chmod u+x d/g; chmod -R a+X d; ls -l d/g | cut -c1-10
fd -t x . d
```
```text
drwx------
drwx------
-rw-------
-rw-------
drwx--x--x
drwx--x--x
-rw-------
-rw-------
-rwx--x--x
d/g
```

`umask` is a mask of the bits that a newly created file or directory does not get. A new file
starts from `666` and a directory from `777`, minus the mask, so `022` gives `644` and `755` and
`077` gives `600` and `700`. Files are never created executable. It affects new files only, not
`chmod`, and a shell changes its own umask (`umask 077` in a subshell stays there):

```sh
# spec: CLI-PERM-05
umask 022; touch a; mkdir b; ls -ld a b | cut -c1-10
umask 077; touch c; mkdir e; ls -ld c e | cut -c1-10
umask 000; touch g; ls -l g | cut -c1-10
( umask 077; touch h ); touch i; ls -l h i | cut -c1-10
```
```text
-rw-r--r--
drwxr-xr-x
-rw-------
drwx------
-rw-rw-rw-
-rw-------
-rw-rw-rw-
```

A script has to be executable to be started by its path, otherwise the shell answers
`Permission denied` and the status is 126:

```sh
# spec: CLI-PERM-06
printf '#!/bin/sh\necho ran\n' > s.sh
./s.sh 2>/dev/null; echo "status: $?"
chmod u+x s.sh
./s.sh
```
```text
status: 126
ran
```

A fourth, leading octal digit sets the special bits: 4 is setuid (`s` in the owner's `x`), 2 setgid,
1 the sticky bit (`t` in the others' `x`, as on a shared `/tmp`). `install -m` copies a file and sets
its mode in one step, and `mkdir -m` makes a directory with a mode:

```sh
# spec: CLI-PERM-07
umask 022; echo a > s
install -m 755 s i; ls -l i | cut -c1-10
chmod 4755 i; ls -l i | cut -c1-10
mkdir -m 700 m; ls -ld m | cut -c1-10
chmod 1777 m; ls -ld m | cut -c1-10
```
```text
-rwxr-xr-x
-rwsr-xr-x
drwx------
drwxrwxrwt
```

An invalid mode is an error with status 1 and changes nothing. A user may `chown` a file they own
to themselves (and `chgrp` it to a group they belong to), which is allowed and changes nothing
here; changing the owner to someone else needs root:

```sh
# spec: CLI-PERM-08 CLI-PERM-18
touch f; chmod 600 f
chmod u+q f 2>/dev/null; echo "status: $?"
chmod 999 f 2>/dev/null; echo "status: $?"
ls -l f | cut -c1-10
chown "$(id -un):$(id -gn)" f; echo "status: $?"
```
```text
status: 1
status: 1
-rw-------
status: 0
```

## Differences that change results

- **Octal replaces, symbolic adjusts.** `chmod 640 f` sets all nine bits; `chmod g+w f` changes
  one and keeps the rest, and `=` resets the named triples (`go=` clears both). `a+X` and
  `chmod -R` give a different result on files and directories.
- **`x` on a directory is "enter".** A directory needs `x` to reach what is inside and `w` (and
  `x`) to create or delete entries, and `r` only to list names. `chmod 600 dir` is a common
  mistake: the names can be listed, but nothing inside can be opened.
- **Deleting depends on the directory.** A read-only file can be removed from a writable directory
  and a writable file cannot be removed from a read-only one.
- **`-R` and `X`.** `chmod -R +x` makes every plain file executable too; `chmod -R a+X` makes the
  directories enterable and leaves plain files alone. `-R` follows no symlink by default on BSD
  (`-H`, `-L` and `-P` choose).
- **`umask` applies only at creation.** New files and directories lose the masked bits, files never
  start executable, and an existing file is not touched. A `chmod` with a who letter (`a+r`) is not
  limited by the umask, so `chmod g+r f` works under `umask 077`.
- **Special bits.** A fourth leading digit sets setuid (4), setgid (2) and the sticky bit (1), and
  `ls -l` shows them as `s` or `t` in the execute positions. `stat -f %Lp` (BSD) does not print them
  in its three digits; `%Sp` prints the string.
- **Ownership needs privilege.** A normal user cannot give a file away: `chown OTHER f` needs root, and
  `chgrp` only accepts a group the user belongs to; `chown` to oneself is allowed.
- **Invalid modes.** `chmod` exits 1 with `Invalid file mode` and changes nothing.
- **BSD versus GNU.** `chmod --reference=FILE`, `chown --reference` and the long options are GNU
  only (macOS prints its usage and exits 1); `stat -c %a` is the GNU way to read an octal mode
  and `stat -f %Lp` the BSD way, so a portable script reads the mode with `ls -l`. macOS also has
  ACLs (`chmod +a`, `ls -le`) and flags (`chflags`) that `chmod` does not show in the ten characters.

## When to keep the classic command

- These four are the tools: there is nothing to replace them with. In a POSIX script use the octal
  form or the POSIX symbolic forms (`u+x`, `go-w`, `a=r`), and `ls -ld` rather than `stat` to
  read a mode.
- To copy a file and set its mode in one step, `install -m 755 SRC DST`; to create a directory with a
  mode, `mkdir -m 700 DIR`. Both give the result of `cp` or `mkdir` followed by `chmod`.
- To read permissions in a listing, `ls -l` or `eza -l` (`list-dirs.md`); `eza` also colours and
  groups, which a script should not parse.
- To list the executable files of a tree, `fd -t x` (`find-files.md`).

## Pitfalls

`chmod -R 777` makes every file readable, writable and executable by everyone, and does not fix a
`Permission denied` that comes from a missing `x` on a directory or from the owner. Set what the
mode needs: `go-rwx` to make a tree private, `a+X` to make it enterable:

```sh bad
chmod -R 777 d
```
```sh
# spec: CLI-PERM-04
mkdir -p d/e; touch d/e/f d/g
chmod -R go-rwx d
ls -ld d d/e d/e/f d/g | cut -c1-10
```
```text
drwx------
drwx------
-rw-------
-rw-------
```

## Sources

None in the catalog: to be cited by the lead.
