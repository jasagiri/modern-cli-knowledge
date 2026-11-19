# List and search processes: procs

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

`procs` lists all processes, `procs --tree` shows parents and children, and `procs --watch`
refreshes the list until interrupted, like `top`. The columns (PID, user, CPU, memory, command)
and their colours are chosen by procs, and the table adapts to the terminal width. What they
print is the process table of the machine, so these three have no output that an example could
check; the examples below use a process the example itself starts.

A keyword keeps only the processes that match. A non-numeric keyword matches the User and Command
columns (partial match). Here the example starts `sleep 4711` in the background and finds it by
the word `sleep`; the `select` keeps that one process, because the shell running the example is
also a match for the word:

```sh
sleep 4711 &
P=$!
procs --json sleep | jq -r ".[] | select(.PID == $P) | .Command"
kill $P
```
```text
sleep 4711
```

A numeric keyword matches the PID exactly (not a port, and not text in the command line):

```sh
sleep 4711 &
P=$!
procs --json $P | jq -r ".[].Command"
procs --json 4711 | jq length
kill $P
```
```text
sleep 4711
0
```

`--json` prints machine-readable output instead of the table. Each process is an object with the
columns that are shown:

```sh
procs --json | jq -r ".[0] | keys | join(\", \")"
```
```text
CPU, CPU Time, Command, MEM, PID, TTY, User
```

When piped, procs prints no colour and no pager, but still the boxed table with its header;
`--no-header` drops the header. The two commands count how many of the first lines contain the
header's `PID:` (1, then 0; `grep -c` exits 1 when it counts 0, so `|| true`):

```sh
procs | head -n 1 | grep -c "PID:"
procs --no-header | head -n 1 | grep -c "PID:" || true
```
```text
1
0
```

## Differences that change results

- **Keyword search is per column.** `ps aux | grep nginx` matches any text in the line, including
  the `grep` process itself. `procs nginx` matches a non-numeric keyword against User and Command
  only, and `procs 8080` matches the PID 8080 exactly, not a TCP port. Other columns are searched
  only if the configuration says so (`nonnumeric_search`, `numeric_search`). Several keywords must
  all match (AND); `--or`, `--and`, `--nand` and `--nor` change that.
- **Different columns and units.** procs shows human-readable sizes in a table, and can show more
  than `ps` (TCP and UDP ports, Docker container names, read and write throughput; see
  `procs --list` for the column kinds); a script that cuts fields by position from `ps` output
  cannot read it.
- **Piped output.** When piped, procs prints no colour and no pager, but still the boxed table
  with its two-line header (the config option `cut_to_pipe` is false by default). `--json` gives
  JSON, `--no-header` drops the header, `--only <kind>` selects a column kind, and
  `--color disable` and `--pager disable` turn colour and pager off.
- **`--json` with `--tree` or `--only`.** In procs 0.14.12 the output of `--json` combined with
  `--tree` or `--only` is not valid JSON (jq stops with a parse error); use `--json` alone and
  select with `jq`.
- **Other users' processes.** The README says that on macOS a normal user cannot access any
  information on other users' processes, and on Linux not some of it (such as throughput), unless
  procs runs with `sudo`. On the checking machine (macOS, no `sudo`) every listed process
  belonged to the current user, so the list is shorter than `ps aux`.
- **Configuration.** procs reads a configuration file for columns and style, so two machines can
  print different tables from the same command; `ps` output formats are fixed by `-o`.
- **Platform.** The `ps` options differ between BSD (macOS) and GNU (Linux). procs takes the same
  command line everywhere, but the available columns depend on the OS (Cgroup is Linux only,
  Docker and UdpPort are not available on Windows and FreeBSD), and its README lists Linux and
  Windows as supported and macOS and FreeBSD as experimental.

## When to keep the classic command

- Scripts and one-liners that must run on servers, containers and rescue shells where procs is not
  installed: `ps` is always there.
- When a fixed, parseable format is needed and `--json` is not an option: `ps -o pid=,comm= -p PID`.
- When a column procs does not show, or the exact `ps` field, is the point.

## Pitfalls

A numeric keyword is a PID, so it never matches text in the command line. Combined with a word
the two keywords (AND) match nothing, because no process has that number as its PID:

```sh bad
procs --json sleep 4711
```
Search by the word, then pick the process in the JSON:

```sh
sleep 4711 &
P=$!
procs --json sleep | jq -r ".[] | select(.Command | endswith(\"4711\")) | .Command"
kill $P
```
```text
sleep 4711
```

## Sources

- `88c4d3aa0d62e881` procs
- `74e831fd938988b8` POSIX.1-2024 Shell and Utilities: utilities
