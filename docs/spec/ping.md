# Spec table: ping

One row per claim of the sections "Differences that change results" (D) and "When to keep the classic command" (K) of `skills/modern-cli/details/ping.md`. 例 = an example of the page names the ID in a `# spec:` line; 本文のみ = no example does, for the category and reason given (MCLI-SPEC-02).

| ID | 箇所 | 主張 | 確かめ |
|---|---|---|---|
| CLI-GPING-01 | D1 | Without a terminal gping draws nothing and exits 1, with `--cmd` too | 例 |
| CLI-GPING-02 | D2 | gping has no option to stop after a number of probes; `ping -c N` stops after N | 例 |
| CLI-GPING-03 | D3 | gping's options are `-n` (interval), `-b` (seconds in the graph) and `--cmd` (time commands) | 例 |
| CLI-GPING-04 | D4 | gping prints nothing on standard output for a program to read; `ping -c N -q` prints a summary line | 例 |
| CLI-GPING-05 | D4 | The wording of ping's summary differs between BSD and GNU | 本文のみ (機械: no GNU ping on the checking machine) |
| CLI-GPING-06 | D5 | gping exits 1 on a usage error as well as without a terminal | 例 |
| CLI-GPING-07 | D5 | ping exits non-zero when no reply arrived (2 on macOS, 1 with GNU ping) and for a name that does not resolve (68 on macOS, 2 with GNU) | 本文のみ (通信: a host that does not answer means sending probes out over the network) |
| CLI-GPING-08 | D6 | The examples were checked with gping 1.21.0 | 本文のみ (版: the version is checked by MCLI-VER-01 in docs/tool-versions.md, not by an example) |
| CLI-GPING-09 | K1 | Keep `ping -c N` and its status for scripts, health checks and CI | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-GPING-10 | K2 | Keep `ping -c N -q` to measure or keep packet loss | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-GPING-11 | K3 | Keep `ping` on hosts without gping | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-GPING-12 | D5 | ping exits 0 when a reply arrived and 64 on a usage error (macOS) | 例 |
