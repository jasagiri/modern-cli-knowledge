# Show free disk space per mount: duf

## Intent

See how full each mounted filesystem is, grouped by kind (local, network, special), in a table
with usage bars, instead of the plain `df` listing.

## Classic and modern

| classic | modern |
|---|---|
| `df -h` | `duf` |
| `df -h /path` | `duf /path` |
| `df -h \| grep ...` | `duf -only local` |
| `df -i` | `duf -inodes` |

## Commands

`duf` shows the mounted filesystems as tables grouped by type, with usage bars; `duf /path`
shows only the filesystem that holds the path; `duf -only local` shows only local disks;
`duf -inodes` shows inode use instead of block use. The tables list the mounts, sizes and
usage of the machine, so no example can check their content; the examples below check what does
not depend on the machine.

The groups are `local`, `network`, `fuse`, `special`, `loops` and `binds`, in both `-only` and
`-hide` (the help names them twice):

```sh
# spec: CLI-DUF-01
duf -help 2>&1 | grep -c "local, network, fuse, special, loops, binds"
```
```text
2
```

Print machine-readable JSON, for a script. `-json` ignores `-only` and path arguments and prints
every device, so filter the result with `jq` (the root of the filesystem is a `local` device, and
`-json -only local /tmp` lists exactly as many devices as plain `-json`):

```sh
# spec: CLI-DUF-03
duf -json | jq -r ".[] | select(.mount_point == \"/\") | .device_type"
[ "$(duf -json | jq length)" = "$(duf -json -only local /tmp | jq length)" ] && echo same
```
```text
local
same
```

The fields of each device in the JSON of duf 0.9.1 (sizes are in bytes):

```sh
# spec: CLI-DUF-03
duf -json | jq -r ".[0] | keys | join(\", \")"
```
```text
block_size, blocks, device, device_type, free, fs_type, inodes, inodes_free, inodes_used, mount_point, opts, total, type, used
```

A path selects the filesystem that holds it: `duf /tmp` shows only the device under `/tmp` (one
line on the checking machine; what that device is depends on the machine, so this is not run here).

## Differences that change results

- **Default selection.** duf shows local, network, fuse and special groups (such as devfs) by
  default. `-all` also includes pseudo, duplicate and inaccessible filesystems, so a mount that
  `df` shows may be missing without it (on the checking machine `duf -all` listed 13 local devices
  and `duf` 12).
- **Grouped output.** The table is split into groups with one heading each; there is no single
  list to cut with `awk '{print $5}'`. For scripts use `-json` (all devices, filter with `jq`) or
  `-output` to pick columns.
- **Sizes.** duf shows human-readable sizes; `df` shows 512-byte blocks on BSD unless `-h` or `-k`.
- **Flags.** duf takes Go-style single-dash flags (`-only`, `-json`); `df` uses POSIX options
  (`-h`, `-k`, `-i`). Flags must come before the paths: `duf -json /tmp` works, `duf /tmp -json`
  reads `-json` as a path and fails with an `lstat` error.
- **Platform.** BSD and GNU `df` differ in columns and flags (`df -T` is GNU only); duf prints the
  same table on both.

## When to keep the classic command

- POSIX scripts, containers and servers without duf: `df -P` has a specified format.
- When a script parses the output: `df -Pk` gives one line per filesystem in 1024-byte blocks.

## Pitfalls

Options placed after a path are read as paths, so the command fails and the option has no effect:

```sh bad
duf /tmp -only local
```
Put the flags first:

```sh
# spec: CLI-DUF-05
duf -only local /tmp > /dev/null; echo "exit $?"
```
```text
exit 0
```

The failure is status 1 with an `lstat` error on standard output (the `sed` hides the working
directory that the message names):

```sh
# spec: CLI-DUF-05
out=$(duf /tmp -only local); echo "exit $?"
echo "$out" | sed "s#^lstat .*/-only#lstat -only#"
```
```text
exit 1
lstat -only: no such file or directory
```

## Sources

- `137001351adaa63a` duf
- `74e831fd938988b8` POSIX.1-2024 Shell and Utilities: utilities
