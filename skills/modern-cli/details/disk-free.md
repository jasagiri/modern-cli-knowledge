# Show free disk space per mount: duf

Status: 未検証 (output depends on the machine's mounts)

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

Show the mounted filesystems as tables grouped by type, with usage bars:

```sh unverified
duf
```

Show only the filesystem that holds a path:

```sh unverified
duf /home
```

Show only local disks (the groups are `local`, `network`, `fuse`, `special`, `loops`, `binds`):

```sh unverified
duf -only local
```

Print machine-readable JSON, for a script. `-json` ignores `-only` and path arguments and prints
every device, so filter the result with `jq`:

```sh unverified
duf -json | jq -r '.[] | select(.device_type == "local") | .mount_point'
```

## Differences that change results

- **Default selection.** duf shows local, network, fuse and special groups (such as devfs) by
  default. `-all` also includes pseudo, duplicate and inaccessible filesystems, so a mount that
  `df` shows may be missing without it.
- **Grouped output.** The table is split into groups with one heading each; there is no single
  list to cut with `awk '{print $5}'`. For scripts use `-json` (all devices, filter with `jq`) or
  `-output` to pick columns.
- **Sizes.** duf shows human-readable sizes; `df` shows 512-byte blocks on BSD unless `-h` or `-k`.
- **Flags.** duf takes Go-style single-dash flags (`-only`, `-json`); `df` uses POSIX options
  (`-h`, `-k`, `-i`). Flags must come before the paths: `duf -json /tmp` works, `duf /tmp -json`
  fails because `-json` is read as a path.
- **Platform.** BSD and GNU `df` differ in columns and flags (`df -T` is GNU only); duf prints the
  same table on both.

## When to keep the classic command

- POSIX scripts, containers and servers without duf: `df -P` has a specified format.
- When a script parses the output: `df -Pk` gives one line per filesystem in 1024-byte blocks.

## Pitfalls

Options placed after a path are read as paths, so the command fails with an `lstat` error and
the option has no effect. Put the flags first:

```sh unverified
duf -only local /home
```

## Sources

- `137001351adaa63a` duf
- `74e831fd938988b8` POSIX.1-2024 Shell and Utilities: utilities
