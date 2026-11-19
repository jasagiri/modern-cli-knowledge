# Spec table: processes

One row per claim of the sections "Differences that change results" (D) and "When to keep the classic command" (K) of `skills/modern-cli/details/processes.md`. 例 = an example of the page names the ID in a `# spec:` line; 本文のみ = no example does, for the reason given (MCLI-SPEC-02).

| ID | 箇所 | 主張 | 確かめ |
|---|---|---|---|
| CLI-PROCS-01 | D1 | A non-numeric keyword matches the User and Command columns and a numeric one the PID exactly; several keywords must all match | 例 |
| CLI-PROCS-02 | D2 | procs shows human-readable sizes and can show more than `ps` (TCP and UDP ports, Docker names, throughput) | 例 |
| CLI-PROCS-03 | D3 | Piped, procs prints no colour and no pager but the boxed table with its header, and `--no-header` drops the header | 例 |
| CLI-PROCS-04 | D4 | In procs 0.14.12 `--json` combined with `--tree` or `--only` is not valid JSON | 例 |
| CLI-PROCS-05 | D5 | On macOS a normal user sees only their own processes, and on Linux some information of other users is missing, unless procs runs with `sudo` | 本文のみ (what is listed depends on the OS and privileges of the machine) |
| CLI-PROCS-06 | D6 | procs reads a configuration file for columns and style, so two machines can print different tables | 本文のみ (the example machine has no configuration file) |
| CLI-PROCS-07 | D7 | The available columns depend on the OS and procs is experimental on macOS and FreeBSD | 本文のみ (other operating systems are not available to an example) |
| CLI-PROCS-08 | K1 | Keep `ps` in scripts and one-liners where procs is not installed | 本文のみ (advice on when to choose, not a result) |
| CLI-PROCS-09 | K2 | Keep `ps -o pid=,comm= -p PID` when a fixed, parseable format is needed and `--json` is not an option | 本文のみ (advice on when to choose, not a result) |
| CLI-PROCS-10 | K3 | Keep `ps` when a column procs does not show is the point | 本文のみ (advice on when to choose, not a result) |
