# Disk usage: dust

## Intent

See which files and directories take the most space, as a tree sorted by size, without piping
`du` through `sort` and `head`.

## Classic and modern

| classic | modern |
|---|---|
| `du -sh DIR` | `dust -d 0 DIR` |
| `du -h -d 1 DIR \| sort -h` | `dust -d 1 DIR` |
| `du -A -k DIR` (macOS) / `du --apparent-size -k DIR` (GNU) | `dust -s DIR` |
| `du -a DIR \| sort -n \| tail` | `dust -n 10 DIR` |
| `find DIR -type f \| wc -l` | `dust -f DIR` (file counts) |

## Commands

The examples use `-s` (apparent size, the length of the file), `-b` (no percentage bars, which
depend on the terminal width) and `-P` (no progress line). Apparent sizes are the same on every
machine. Without `-s`, dust reports blocks on disk, which depend on the filesystem and are
therefore not shown here. Directory rows that include the directory entries themselves have the
same dependence, so the examples hide them (`--skip-total`) or filter to files (`-e`).

The files of a directory, smallest first, the largest at the bottom next to the directory (`-d 1`
limits the depth, `--skip-total` drops the row for `notes` itself):

```sh
# spec: CLI-DUST-01 CLI-DUST-04 CLI-DUST-08
dust -s -b -P --skip-total -d 1 notes
```
```text
 26B ┌── 日本語.txt
 36B ├── meeting notes.txt
 53B ├── todo.txt
```

Reverse the order, biggest first (`-r`):

```sh
# spec: CLI-DUST-04
dust -s -b -P --skip-total -d 1 -r notes
```
```text
 53B ├── todo.txt
 36B ├── meeting notes.txt
 26B └── 日本語.txt
```

Keep only the n largest entries (`-n`), or only those of at least a size (`-z`):

```sh
# spec: CLI-DUST-05
dust -s -b -P --skip-total -d 1 -n 2 notes && dust -s -b -P --skip-total -d 1 -z 50 notes
```
```text
 36B ┌── meeting notes.txt
 53B ├── todo.txt
 53B ┌── todo.txt
```

Sizes of 1024 bytes and more get a unit. dust uses powers of 1024 (`Ki`), `-o si` powers of 1000
(`K`) and `-o b` bytes. BSD `du -A` (apparent size) counts 512-byte blocks, and `-k` KiB, both
rounded up:

```sh
# spec: CLI-DUST-07
mkdir big && head -c 3000 /dev/zero > big/zeros.bin
dust -s -b -P --skip-total big
dust -s -b -P --skip-total -o si big
dust -s -b -P --skip-total -o b big
du -A big/zeros.bin; du -Ak big/zeros.bin
```
```text
2.9Ki ┌── zeros.bin
3.0K ┌── zeros.bin
3000B ┌── zeros.bin
6	big/zeros.bin
3	big/zeros.bin
```

Count only the files whose path matches a regex (`-e`; `-v` is the opposite). The directory row
is then the exact sum of those files:

```sh
# spec: CLI-DUST-03
dust -s -b -P -e '\.(nim|py)$' src
```
```text
 55B   ┌── legacy.py
 83B   ├── main.nim
 96B   ├── util.nim
234B ┌─┴ src
```

Full paths instead of names relative to the row above (`-p`), useful when the output is read
without the tree:

```sh
dust -s -b -P --skip-total -p -d 1 notes
```
```text
 26B ┌── notes/日本語.txt
 36B ├── notes/meeting notes.txt
 53B ├── notes/todo.txt
```

Count files instead of bytes (`-f`):

```sh
dust -f -b -P -d 1 src
```
```text
1   ┌── legacy.py
1   ├── main.nim
1   ├── util.nim
3 ┌─┴ src
```

dust counts hidden files, and it does not read `.gitignore`: `debug.log` is ignored by the
fixture's `.gitignore` and `.hidden` is hidden, and both are listed; `-i` skips the hidden one:

```sh
# spec: CLI-DUST-09
dust -s -b -P --skip-total -d 1 -e 'debug.log|hidden' .
dust -s -b -P --skip-total -d 1 -i -e 'debug.log|hidden' .
```
```text
 15B ┌── debug.log
114B ├── .hidden
15B ┌── debug.log
```

A path that cannot be read is reported on standard error, and when no path can be read the status
is 1:

```sh
# spec: CLI-DUST-10
# exit: 1
dust -s -b -P nope
```
```text
```

A missing path among readable ones is still reported on standard error, but the status stays 0:

```sh
# spec: CLI-DUST-10
dust -s -b -P --skip-total -d 1 nope notes > /dev/null 2>&1; echo "status: $?"
```
```text
status: 0
```

## Differences that change results

- **Blocks versus length.** `du` and `dust` both report blocks allocated on disk by default, so a
  12-byte file shows as 4 KiB (or whatever the filesystem allocates), and the numbers differ per
  filesystem. `dust -s` and `du -A` (macOS) / `du --apparent-size` (GNU) report the length of the
  file. Sparse files, compressed filesystems and hard links make the two diverge; neither is
  "wrong".
- **Directory rows.** A directory's size includes the space of its own entry, which varies by
  filesystem (APFS, ext4 and tmpfs differ), so the total of a directory is not the sum of its files'
  lengths even with `-s`. With `-e` or `-v` the directory entries are left out, and the sum is exact.
- **Order.** dust prints smallest first and the root last, bars on the left of the tree; `-r`
  prints biggest first. `du` prints in walk order and needs `sort -n`.
- **Depth and count.** dust shows only the largest rows that fit the terminal height unless `-n` is
  given; `du` prints every directory. Pass `-n` and `-d` in scripts, since the terminal height
  differs between runs.
- **Units.** dust prints human units with powers of 1024 (`Ki`, `Mi`); `-b`-style exact bytes are
  `-o b`, `-o si` uses powers of 1000. BSD `du` uses 512-byte blocks unless `-k`, `-h` or
  `BLOCKSIZE` is set, GNU `du` 1024 bytes.
- **Percent bars and progress.** Bars and a progress line appear when dust runs on a terminal; their
  width depends on the terminal. `-b` and `-P` remove them, which is what a script wants.
- **Hidden files and `.gitignore`.** dust counts hidden files (use `-i` to skip them) and does not
  read `.gitignore`, like `du`.
- **Exit status.** 0 when at least one path could be read (a missing path among valid ones is still
  reported on standard error but does not change the status, checked with dust 1.2.7), 1 when none
  could. `du` exits 1 as soon as any path fails.

## When to keep the classic command

- POSIX scripts, CI images and servers without dust: use `du -k` (or `du -sk`), which prints one
  number per path in a fixed unit that other tools parse.
- When a script needs one machine-readable number per path (`du -sk DIR | cut -f1`): the tree
  output of dust is for reading.
- When an exact disk-usage figure per directory is the question and matches what `df` reports:
  `du` and `dust` without `-s` agree; with `-s` you ask a different question.

## Pitfalls

Output with the default options depends on the terminal (height, width, bars) and on the filesystem
(blocks), so copying it into a document or a test makes the document differ between machines. Fix
the options that matter:

```sh bad
dust notes
```
```sh
# spec: CLI-DUST-01 CLI-DUST-04 CLI-DUST-08
dust -s -b -P --skip-total -d 1 notes
```
```text
 26B ┌── 日本語.txt
 36B ├── meeting notes.txt
 53B ├── todo.txt
```

## Sources

- `4c9c6183d8fb405c` dust
- `74e831fd938988b8` POSIX.1-2024 Shell and Utilities: utilities
- `e372d8114adfc35f` The Linux Command Line
