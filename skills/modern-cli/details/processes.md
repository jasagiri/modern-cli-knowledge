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
| `kill PID`, `kill -KILL PID` | none (keep `kill`; find the PID with `procs`) |

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
# spec: CLI-PROCS-01
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
# spec: CLI-PROCS-01
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
# spec: CLI-PROCS-03
procs | head -n 1 | grep -c "PID:"
procs --no-header | head -n 1 | grep -c "PID:" || true
```
```text
1
0
```

`procs --list` names the column kinds; the ones beyond `ps` include the ports and the Docker name.
`--json` combined with `--tree` or `--only` is not valid JSON in this version (jq cannot parse it,
status 5), `--json` alone is:

```sh
# spec: CLI-PROCS-02 CLI-PROCS-04
procs --list | grep -c -E '^ *(TcpPort|UdpPort|Docker) '
procs --json --tree 2>/dev/null | jq -r type > /dev/null 2>&1; echo "tree: $?"
procs --json --only Pid 2>/dev/null | jq -r type > /dev/null 2>&1; echo "only: $?"
procs --json | jq -r type > /dev/null 2>&1; echo "plain: $?"
```
```text
3
tree: 5
only: 5
plain: 0
```

### Stop a process: kill and signals

procs only shows processes; stopping one is `kill`, which sends a signal. Every example below starts
its own `sleep` in the background, signals that process by the PID the shell keeps in `$!`, and reads
the status with `wait PID`. A process ended by a signal has the status 128 plus the signal number
(`kill -l 143` names it): `kill` sends TERM (15) by default, so the status is 143. KILL (9) gives
137, HUP (1) 129 and INT (2) 130:

```sh
# spec: CLI-PROCS-11
sleep 30 & P=$!; kill $P; wait $P; echo "status: $?"
sleep 30 & P=$!; kill -KILL $P; wait $P; echo "status: $?"
sleep 30 & P=$!; kill -HUP $P; wait $P; echo "status: $?"
sh -c 'kill -INT $$; sleep 30'; echo "status: $?"
sleep 30 & P=$!; until [ "$(ps -o comm= -p $P)" = sleep ]; do sleep 0.05; done
kill -INT $P; kill -0 $P && echo "INT ignored"; kill $P; wait $P; echo "status: $?"
kill -l 143
```
```text
status: 143
status: 137
status: 129
status: 130
INT ignored
status: 143
TERM
```

A command started with `&` in a script (a shell without job control) ignores INT and QUIT, as POSIX
requires, so `kill -INT` does nothing to it once it runs; only a signal that arrives before the
shell has set this up ends it, which is a race. The example therefore shows 130 with a foreground
`sh` that sends INT to itself, and the background `sleep` still alive after INT.

TERM asks the process to stop and it may catch the signal (here a `trap` runs a handler, which sets
the status 3) or ignore it (`trap "" TERM`: the process is still alive). KILL (and STOP) cannot be
caught or ignored, so `kill -KILL` is the last resort after TERM has failed. Each child creates a
file once its `trap` is set, and the parent waits for that file before it signals, because a signal
that arrives before the `trap` runs gets the default action:

```sh
# spec: CLI-PROCS-12
sh -c 'sleep 30 & c=$!; trap "kill $c; echo got TERM; exit 3" TERM; : > ready1; wait $c' & P=$!
until [ -e ready1 ]; do sleep 0.05; done
kill $P; wait $P; echo "status: $?"
sh -c 'trap "" TERM; : > ready2; sleep 2' & P=$!
until [ -e ready2 ]; do sleep 0.05; done
kill $P; kill -0 $P && echo still-alive
kill -KILL $P; wait $P; echo "status: $?"
```
```text
got TERM
status: 3
still-alive
status: 137
```

Signal 0 sends nothing: `kill -0 PID` only reports whether the process exists and may be signalled
(status 0) or not (status 1, and `kill` says `No such process` on standard error). The status of a
process that has gone is therefore 1 for any later `kill`:

```sh
# spec: CLI-PROCS-13
sleep 30 & P=$!
kill -0 $P; echo "alive: $?"
kill $P; wait $P
kill -0 $P 2>/dev/null; echo "gone: $?"
true & Q=$!; wait $Q
kill $Q 2>/dev/null; echo "finished: $?"
sleep 30 & R=$!; kill -s FOO $R 2>/dev/null; echo "bad name: $?"
kill $R; wait $R; echo "ended: $?"
```
```text
alive: 0
gone: 1
finished: 1
bad name: 1
ended: 143
```

The names `HUP` `INT` `QUIT` `ABRT` `KILL` `ALRM` `TERM` and their numbers 1, 2, 3, 6, 9, 14, 15 are
fixed by POSIX and `kill -l NUMBER` prints the name, while the numbers of the other signals differ
between systems (`USR1` is 30 here). The shell builtin `kill` also takes job numbers (`%1`), and
`wait` without a PID waits for all children and returns 0, whatever their status was; with a PID it
returns that process's status:

```sh
# spec: CLI-PROCS-14 CLI-PROCS-15
kill -l 15; kill -l 30
sleep 30 & a=$!; sleep 30 & b=$!
kill %1 %2; wait; echo "wait: $?"
sleep 30 & a=$!; sleep 30 & b=$!
kill $a; wait $a; echo "a: $?"
kill $b; wait; echo "wait: $?"
```
```text
TERM
USR1
wait: 0
a: 143
wait: 0
```

STOP freezes a process and CONT resumes it. A stopped process has the state `T` in the `STAT` column
of `ps`. `$!` is known as soon as the shell has forked, before the child has become `sleep`; measured
here, a STOP sent in that moment sometimes left the process running (`S`). The example waits until
the process is `sleep`, and reads the state again for up to a second, since a signal is delivered
after `kill` returns:

```sh
# spec: CLI-PROCS-16
sleep 30 & P=$!
until [ "$(ps -o comm= -p $P)" = sleep ]; do sleep 0.05; done
kill -STOP $P
for i in 1 2 3 4 5 6 7 8 9 10; do
  s=$(ps -o stat= -p $P | cut -c1); [ "$s" = T ] && break; sleep 0.1
done
echo "$s"
kill -CONT $P; kill $P; wait $P; echo "status: $?"
```
```text
T
status: 143
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
- **`kill` sends TERM and the status shows the signal.** The default signal is TERM (15), which a
  process may catch or ignore; a process ended by a signal has the status 128 plus the number (TERM
  143, KILL 137, HUP 129, INT 130). KILL and STOP cannot be caught or ignored.
- **Signal 0 and missing processes.** `kill -0 PID` sends nothing and reports only whether the
  process exists (status 0, otherwise 1 with `No such process`); `kill` of a finished process or an
  unknown signal name has status 1. A PID can be reused after its process ended, so a PID kept for
  a long time may name another process.
- **Names and numbers.** The names `HUP` `INT` `QUIT` `ABRT` `KILL` `ALRM` `TERM` and the numbers
  1, 2, 3, 6, 9, 14, 15 are the same on every system; the other numbers are not (`USR1` is 30 on
  macOS and 10 on Linux), so write names, not numbers.
- **`wait` and job numbers.** The builtin `kill` accepts `%1` job numbers, which the program
  `/bin/kill` does not. `wait PID` returns the status of that process, `wait` alone returns 0 for
  any children; stopped processes (STOP) show `T` in `ps` until CONT.
- **`pkill` and `pgrep` match patterns.** `pkill -f PATTERN` signals every process of the user whose
  command line matches, so a pattern that is too short kills processes that were not meant; use the
  PID of a process you started (`$!`).

## When to keep the classic command

- Scripts and one-liners that must run on servers, containers and rescue shells where procs is not
  installed: `ps` is always there.
- When a fixed, parseable format is needed and `--json` is not an option: `ps -o pid=,comm= -p PID`.
- When a column procs does not show, or the exact `ps` field, is the point.
- To stop a process, `kill` stays the tool, since procs only lists. Send TERM first, wait for the
  process to end, and use `kill -KILL` only when it did not.
- In a script, signal the PID that the script got from `$!`, not a name found by `pgrep` or
  `pkill`, which can hit other processes.

## Pitfalls

A numeric keyword is a PID, so it never matches text in the command line. Combined with a word
the two keywords (AND) match nothing, because no process has that number as its PID:

```sh bad
procs --json sleep 4711
```
Search by the word, then pick the process in the JSON:

```sh
# spec: CLI-PROCS-01
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
