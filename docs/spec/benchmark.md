# Spec table: benchmark

One row per claim of the sections "Differences that change results" (D) and "When to keep the classic command" (K) of `skills/modern-cli/details/benchmark.md`. 例 = an example of the page names the ID in a `# spec:` line; 本文のみ = no example does, for the category and reason given (MCLI-SPEC-02).

| ID | 箇所 | 主張 | 確かめ |
|---|---|---|---|
| CLI-HYPERFINE-01 | D1 | `--runs N` fixes the number of measured runs and `--warmup N` adds runs that are not recorded | 例 |
| CLI-HYPERFINE-02 | D1 | Without `--runs` hyperfine chooses the number of runs itself (at least 10); `--prepare` and `--setup` run before each run and before each set of runs | 本文のみ (時間: the default count and the hook timing depend on the measured time, so nothing is asserted) |
| CLI-HYPERFINE-03 | D2 | The benchmarked command's standard output is discarded unless `--show-output` is given | 例 |
| CLI-HYPERFINE-04 | D3 | The default runs the command without a shell, so a pipeline is refused unless `-S` | 例 |
| CLI-HYPERFINE-05 | D4 | A benchmarked command that exits non-zero aborts the run (status 1) unless `-i`, and the exit codes stay in the export | 例 |
| CLI-HYPERFINE-06 | D5 | The 2.0.0 JSON export has `primary_metric` and `measurements[]` with `time_wall_clock` and a unit, and no `times` array | 例 |
| CLI-HYPERFINE-07 | D6 | Two runs of the same benchmark give different numbers, so compare the spread and keep timings out of tests and documents | 本文のみ (助言: advice about nondeterminism, nothing to assert) |
| CLI-HYPERFINE-08 | D7 | For commands of a few milliseconds the start-up dominates and hyperfine warns | 本文のみ (時間: the warning depends on measured timing) |
| CLI-HYPERFINE-09 | D8 | The examples were checked with hyperfine 2.0.0 | 本文のみ (版: the version is checked by MCLI-VER-01 in docs/tool-versions.md, not by an example) |
| CLI-HYPERFINE-10 | K1 | Keep `time cmd` for one quick look in an interactive shell | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-HYPERFINE-11 | K2 | Keep `time` or `/usr/bin/time` in POSIX scripts without hyperfine | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-HYPERFINE-12 | K3 | Keep `time` for one run of a long job, and say it is a single sample | 本文のみ (助言: advice on when to choose, not a result) |
