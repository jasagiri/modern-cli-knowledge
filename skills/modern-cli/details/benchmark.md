# Measure and compare command run time: hyperfine

## Intent

Compare how long commands take with repeated runs, warm-up and statistics, instead of reading the
single, noisy number that `time` prints for one run.

Timings differ on every run and on every machine, so this page never shows one. The examples check
only what is deterministic: which commands were run, with which parameters, how many runs were
recorded, and the exit codes. The numbers are read from the JSON export (`--export-json`), never
from the text hyperfine prints.

## Classic and modern

| classic | modern |
|---|---|
| `time cmd` | `hyperfine 'cmd'` |
| `time cmd; time other` (compare by eye) | `hyperfine 'cmd' 'other'` |
| `for n in 1 2 3; do time cmd $n; done` | `hyperfine -P n 1 3 'cmd {n}'` |
| `for t in a b; do time cmd $t; done` | `hyperfine -L t a,b 'cmd {t}'` |
| `time cmd` repeated 10 times and averaged by hand | `hyperfine --runs 10 'cmd'` |
| `cmd > out.txt; time cmd` (show output) | `hyperfine --show-output 'cmd'` |

## Commands

Compare two commands and keep the result as JSON. Standard output is discarded because it holds
timings; `jq` reads back which commands were measured:

```sh
hyperfine --runs 2 --export-json r.json 'true' 'echo hi' > /dev/null && jq -r '.results[].command' r.json
```
```text
true
echo hi
```

Give each command a label with `-n` (the label is the `name` field, the command stays in
`command`):

```sh
hyperfine --runs 2 -n first 'true' -n second 'echo hi' --export-json r.json > /dev/null && jq -r '.results[] | [.name, .command] | @tsv' r.json
```
```text
first	true
second	echo hi
```

Scan a numeric parameter with `-P NAME MIN MAX` (and `-D` for the step); `{n}` is replaced in the
command:

```sh
hyperfine --runs 2 -P n 1 5 -D 2 --export-json r.json 'true {n}' > /dev/null && jq -r '.results[].command' r.json
```
```text
true 1
true 3
true 5
```

Compare a list of values with `-L NAME a,b`. The parameters are recorded per result:

```sh
hyperfine --runs 2 -L tool cat,wc --export-json r.json 'echo {tool}' > /dev/null && jq -r '.results[] | [.command, .parameters.tool.value] | @tsv' r.json
```
```text
echo cat	cat
echo wc	wc
```

`--runs` fixes the number of measured runs and `--warmup` adds runs that are not recorded. Where
the numbers live in the 2.0 JSON: one entry per run in `measurements`, each with the metric
`time_wall_clock` and its unit:

```sh
# spec: CLI-HYPERFINE-01 CLI-HYPERFINE-06
hyperfine --runs 5 --warmup 2 --export-json r.json 'true' > /dev/null && jq -r '.primary_metric, .results[0].measurements[0].time_wall_clock.unit, (.results[0].measurements | length), (.results[0] | has("times"))' r.json
```
```text
time_wall_clock
second
5
false
```

A command that exits non-zero stops the benchmark (hyperfine exits 1); `-i` (`--ignore-failure`)
measures it anyway and the exit codes stay in the export:

```sh
# spec: CLI-HYPERFINE-05
hyperfine --runs 2 'false' > /dev/null 2>&1; echo "stopped: $?"; hyperfine --runs 2 -i --export-json r.json 'false' > /dev/null 2>&1; echo "ignored: $?"; jq -c '.results[0].measurements | map(.exit_code)' r.json
```
```text
stopped: 1
ignored: 0
[1,1]
```

Show what the benchmarked command prints with `--show-output` (it is hidden otherwise). The first
two lines are the output of the two runs; the statistics that follow are not shown:

```sh
# spec: CLI-HYPERFINE-03
hyperfine --runs 2 --show-output 'echo hi' | head -2
```
```text
hi
hi
```

## Differences that change results

- **Many runs, not one.** `time` measures one run and includes whatever was cold: disk cache, first
  load of the binary. hyperfine runs the command repeatedly (it chooses the number of runs itself, at
  least 10 by default, unless `--runs N`) and reports mean, spread, minimum and maximum. Use `--warmup N` for I/O-heavy commands
  and `--prepare CMD` to reset state before each run (`--setup CMD` runs before each set of runs: once per benchmarked command or parameter value, not
  once overall).
- **Output goes to hyperfine.** The benchmarked command's standard output is discarded unless
  `--show-output` is given. Do not benchmark a command that writes a file and expect to see the
  result without checking it.
- **Shell syntax needs `-S`.** In the checked version (2.0.0) the default is to run the command
  directly, without a shell (`--shell` defaults to `none`). A command with `|`, `&&`, `;` or
  redirections is refused with an error unless `-S`/`--shell=default` (or `--shell=bash` etc.) is
  given; `-N` runs it directly, passing `|` as an argument. Setup, prepare, conclude and cleanup
  commands always use a shell. Check `hyperfine --help` for the default of the version in use.
- **Exit status.** A benchmarked command that exits non-zero aborts the run (hyperfine exits 1)
  unless `-i`; `time` reports the command's timing and its status is the command's status.
- **JSON schema.** In 2.0.0 the export has `schema_version`, `primary_metric` and, per result,
  `command`, `name`, `measurements[]` (each with `time_wall_clock`, `time_user`, `time_system`,
  `exit_code`, …) and `summary`; there is no `times` array and no `mean` on the result here
  (checked: `.results[0].times` is absent). A script written for another schema must check
  `.schema_version` first.
- **Variance is the result.** Two runs of the same benchmark give different numbers. Compare with
  the spread, not only the mean, and do not put a timing in a test or in documentation.
- **Short commands.** For commands of a few milliseconds the process start-up dominates; hyperfine
  warns when a run is much shorter or the first run slower than the rest. Treat such results as a
  comparison of start-up time.
- **Version.** The examples were checked with `hyperfine 2.0.0`.

## When to keep the classic command

- A quick look at how long one command took, once, in an interactive shell: `time cmd`.
- A POSIX script that needs the status and wall time of one run, in places without hyperfine:
  `time` is a shell keyword and `/usr/bin/time` exists nearly everywhere.
- Measuring one run of a long job (minutes) where repeating is too expensive: use `time`, and say
  that it is a single sample.

## Pitfalls

A pipeline is shell syntax, so the default (no shell) refuses it. Ask for a shell with `-S`:

```sh bad
hyperfine --runs 2 'echo a | wc -l'
```
```sh
# spec: CLI-HYPERFINE-04
hyperfine --runs 2 -S --show-output 'echo a | wc -l' | head -2 | tr -d ' '
```
```text
1
1
```

The default refusal is a failed benchmark, status 1, before anything is measured:

```sh
# spec: CLI-HYPERFINE-04
hyperfine --runs 2 'echo a | wc -l' > /dev/null 2>&1; echo "status: $?"
```
```text
status: 1
```

## Sources

- `8453006a26292241` hyperfine
- `e2b344d7c00bdbf6` GNU Bash manual
