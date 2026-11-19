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

Keep only the processes that match a keyword. A non-numeric keyword matches the User and Command
columns (partial match); a numeric keyword matches the PID exactly:

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

Machine-readable output for a script, without the table (`--no-header` drops the header of the
table form):

```sh unverified
procs --json
```

## Differences that change results

- **Keyword search is per column.** `ps aux | grep nginx` matches any text in the line, including
  the `grep` process itself. `procs nginx` matches a non-numeric keyword against User and Command
  only, and `procs 8080` matches the PID 8080 exactly, not a TCP port. Other columns are searched
  only if the configuration says so (`nonnumeric_search`, `numeric_search`). Several keywords must
  all match (AND); `--or`, `--and`, `--nand` and `--nor` change that.
- **Different columns and units.** procs shows human-readable sizes and more columns than `ps`
  (for example TCP and UDP ports and Docker names) in a table; a script that cuts fields by
  position from `ps` output cannot read it.
- **Piped output.** When piped, procs prints no colour and no pager, but still the boxed table
  with its two-line header (the config option `cut_to_pipe` is false by default). `--json` gives
  JSON, `--no-header` drops the header, `--only <kind>` selects a column kind, and
  `--color disable` and `--pager disable` turn colour and pager off.
- **Configuration.** procs reads a configuration file for columns and style, so two machines can
  print different tables from the same command; `ps` output formats are fixed by `-o`.
- **Platform.** The `ps` options differ between BSD (macOS) and GNU (Linux). procs takes the same
  command line everywhere, but the available columns depend on the OS (Cgroup is Linux only,
  Docker and UdpPort are not available on Windows and FreeBSD), and its documentation lists
  Linux as supported and macOS and FreeBSD as experimental.

## When to keep the classic command

- Scripts and one-liners that must run on servers, containers and rescue shells where procs is not
  installed: `ps` is always there.
- When a fixed, parseable format is needed and `--json` is not an option: `ps -o pid=,comm= -p PID`.
- When a column procs does not show, or the exact `ps` field, is the point.

## Pitfalls

A keyword matches the User and Command columns, so a word that is also a user name lists
unrelated processes, and a number is taken as a PID, not as a port. Make the keyword specific, or
combine keywords (AND by default):

```sh unverified
procs --tree nginx
```

## Sources

- `88c4d3aa0d62e881` procs
- `74e831fd938988b8` POSIX.1-2024 Shell and Utilities: utilities
