# Spec table: monitor

One row per claim of the sections "Differences that change results" (D) and "When to keep the classic command" (K) of `skills/modern-cli/details/monitor.md`. 例 = an example of the page names the ID in a `# spec:` line; 本文のみ = no example does, for the category and reason given (MCLI-SPEC-02).

| ID | 箇所 | 主張 | 確かめ |
|---|---|---|---|
| CLI-BTOP-01 | D1 | btop draws a full-screen interface and reads the keyboard, so without a terminal it ends with status 1 and cannot be piped or used in cron | 例 |
| CLI-BTOP-02 | D2 | btop shows CPU cores, memory, disks and network at once where `top` shows a summary | 本文のみ (端末: the screen cannot be shown by an example) |
| CLI-BTOP-03 | D3 | btop keeps its settings in a configuration file, so two machines can look different | 例 |
| CLI-BTOP-04 | D4 | Sorting and filtering are keys inside the interface and a start-up filter is `--filter`, where `top` takes `-o` and `-n` | 例 |
| CLI-BTOP-05 | D5 | `top` flags differ between BSD and GNU while btop has the same interface on both | 例 |
| CLI-BTOP-06 | K1 | Keep `top -l 2` (BSD), `top -b -n 1` (GNU) or `ps` for scripts, logs and one-shot snapshots | 例 |
| CLI-BTOP-07 | K2 | Keep `top` where btop is not installed | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-BTOP-08 | K3 | Keep `top` on narrow or slow terminals | 本文のみ (助言: advice on when to choose, not a result) |
