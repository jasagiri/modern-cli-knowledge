# Spec table: processes

One row per claim of the sections "Differences that change results" (D) and "When to keep the classic command" (K) of `skills/modern-cli/details/processes.md`. 例 = an example of the page names the ID in a `# spec:` line; 本文のみ = no example does, for the category and reason given (MCLI-SPEC-02).

| ID | 箇所 | 主張 | 確かめ |
|---|---|---|---|
| CLI-PROCS-01 | D1 | A non-numeric keyword matches the User and Command columns and a numeric one the PID exactly; several keywords must all match | 例 |
| CLI-PROCS-02 | D2 | procs shows human-readable sizes and can show more than `ps` (TCP and UDP ports, Docker names, throughput) | 例 |
| CLI-PROCS-03 | D3 | Piped, procs prints no colour and no pager but the boxed table with its header, and `--no-header` drops the header | 例 |
| CLI-PROCS-04 | D4 | In procs 0.14.12 `--json` combined with `--tree` or `--only` is not valid JSON | 例 |
| CLI-PROCS-05 | D5 | On macOS a normal user sees only their own processes, and on Linux some information of other users is missing, unless procs runs with `sudo` | 本文のみ (機械: what is listed depends on the OS and privileges of the machine) |
| CLI-PROCS-06 | D6 | procs reads a configuration file for columns and style, so two machines can print different tables | 本文のみ (機械: the example machine has no configuration file) |
| CLI-PROCS-07 | D7 | The available columns depend on the OS and procs is experimental on macOS and FreeBSD | 本文のみ (機械: other operating systems are not available to an example) |
| CLI-PROCS-08 | K1 | Keep `ps` in scripts and one-liners where procs is not installed | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-PROCS-09 | K2 | Keep `ps -o pid=,comm= -p PID` when a fixed, parseable format is needed and `--json` is not an option | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-PROCS-10 | K3 | Keep `ps` when a column procs does not show is the point | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-PROCS-11 | D8 | `kill` sends TERM by default, and a process ended by a signal has the status 128 plus its number (TERM 143, KILL 137, HUP 129, INT 130); a command started with `&` in a script ignores INT and QUIT | 例 |
| CLI-PROCS-12 | D8 | TERM can be caught or ignored and KILL cannot | 例 |
| CLI-PROCS-13 | D9 | `kill -0 PID` sends nothing and reports whether the process exists; `kill` of a finished process or an unknown signal name has status 1 | 例 |
| CLI-PROCS-14 | D10 | `kill -l NUMBER` prints the name; `HUP` `INT` `QUIT` `ABRT` `KILL` `ALRM` `TERM` are fixed and `USR1` is 30 here | 例 |
| CLI-PROCS-15 | D11 | The builtin `kill` accepts `%1` job numbers, `wait PID` returns that process's status and `wait` alone returns 0 | 例 |
| CLI-PROCS-16 | D11 | A stopped process shows `T` in `ps` until CONT | 例 |
| CLI-PROCS-17 | D9 | A PID can be reused after its process ended, so a PID kept for a long time may name another process | 本文のみ (非決定: PID reuse cannot be shown in a fixed example) |
| CLI-PROCS-18 | D10 | `USR1` is 10 on Linux | 本文のみ (機械: no Linux on the checking machine) |
| CLI-PROCS-19 | D11 | The program `/bin/kill` does not accept `%1` job numbers | 本文のみ (機械: not run, the example uses the shell builtin) |
| CLI-PROCS-20 | D12 | `pkill -f PATTERN` signals every process of the user whose command line matches | 本文のみ (機械: an example would signal processes it did not start) |
| CLI-PROCS-21 | K4 | Use `kill`, TERM first and `kill -KILL` only when TERM failed, to stop a process | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-PROCS-22 | K5 | In a script signal the PID from `$!`, not a name found by `pgrep` or `pkill` | 本文のみ (助言: advice on when to choose, not a result) |
