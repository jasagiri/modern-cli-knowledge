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

Print machine-readable JSON, for a script:

```sh unverified
duf -json
```

## Differences that change results

- **Hides special filesystems by default.** `df` lists everything it is given; duf hides pseudo
  and special filesystems unless `-all` is passed, so a mount that `df` shows may be missing.
- **Grouped output.** The table is split into groups with one heading each; there is no single
  list to cut with `awk '{print $5}'`. For scripts use `-json` or `-output` to pick columns.
- **Sizes.** duf shows human-readable sizes; `df` shows 512-byte blocks on BSD unless `-h` or `-k`.
- **Flags.** duf takes Go-style single-dash flags (`-only`, `-json`); `df` uses POSIX options
  (`-h`, `-k`, `-i`).
- **Platform.** BSD and GNU `df` differ in columns and flags (`df -T` is GNU only); duf prints the
  same table on both.

## When to keep the classic command

- POSIX scripts, containers and servers without duf: `df -P` has a specified format.
- When a script parses the output: `df -Pk` gives one line per filesystem in 1024-byte blocks.
- When the hidden special filesystems are what you are asking about, unless `-all` is used.

## Pitfalls

duf hides some filesystems by default, so "it is not listed" does not mean "it is not mounted".
Ask for everything before concluding:

```sh unverified
duf -all
```

## Sources

- `137001351adaa63a` duf
- `74e831fd938988b8` POSIX.1-2024 Shell and Utilities: utilities
