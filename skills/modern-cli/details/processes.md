# List and search processes: procs

Status: 未検証 (output depends on the running processes)

## Intent

Show running processes as a readable table, filter them by a keyword across columns, and show
the parent and child relationship, with colour and units chosen for people.

## Classic and modern

| classic | modern |
|---|---|
| `ps aux` | `procs` |
| `ps aux \| grep nginx` | `procs nginx` |
| `ps -ef --forest` (GNU) | `procs --tree` |
| `watch ps aux` | `procs --watch` |

## Commands

List all processes. The columns (PID, user, CPU, memory, command and more) and their colours are
chosen by procs, and the table adapts to the terminal width:

```sh unverified
procs
```

Keep only the processes where any column contains the keyword (the user name, the command, the
PID and so on, not only the command):

```sh unverified
procs nginx
```

Show the processes as a tree of parents and children:

```sh unverified
procs --tree
```

Refresh the list continuously, like `top`, until interrupted:

```sh unverified
procs --watch
```

## Differences that change results

- **Keyword search covers every displayed column.** `ps aux | grep nginx` matches any text in the
  line, including the `grep` process itself; `procs nginx` matches the columns procs shows, so
  the result depends on which columns are configured.
- **Different columns and units.** procs shows human-readable sizes and more columns than `ps`
  (for example TCP and UDP ports and Docker names) in a table; a script that cuts fields by
  position from `ps` output cannot read it.
- **Colour and width.** The table is coloured and sized for a terminal. Check procs's own
  documentation for how it behaves when its output is piped before depending on it in a script.
- **Configuration.** procs reads a configuration file for columns and style, so two machines can
  print different tables from the same command; `ps` output formats are fixed by `-o`.
- **Platform.** The `ps` options differ between BSD (macOS) and GNU (Linux); procs presents the
  same table on both.

## When to keep the classic command

- Scripts and one-liners that must run on servers, containers and rescue shells where procs is not
  installed: `ps` is always there.
- When a fixed, parseable format is needed: `ps -o pid=,comm= -p PID`.
- When a column procs does not show, or the exact `ps` field, is the point.

## Pitfalls

The keyword is matched against all columns, not only the command, so a keyword that is also a
user name or a number lists unrelated processes. Make the keyword specific, or read the table
instead of counting its lines:

```sh unverified
procs --tree nginx
```

## Sources

- `88c4d3aa0d62e881` procs
- `74e831fd938988b8` POSIX.1-2024 Shell and Utilities: utilities
