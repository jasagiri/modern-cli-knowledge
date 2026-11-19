# Tool versions

The examples were checked with these versions (MCLI-VER-01). `tests/test_versions.nim` runs each
command under the fixed environment and compares the given line of its output (1-based) with the
recorded text. When a tool is upgraded, the test fails and names it: rerun `nim test`, fix the pages
whose output changed, then update the row.

The classic commands on the checking machine are the BSD ones of macOS. Where GNU behaves
differently, the page says so in "Differences that change results"; GNU output is not checked here.

| tool | command | line | recorded | status |
|---|---|---|---|---|
| rg | `rg --version` | 1 | `ripgrep 15.2.0` | verified |
| fd | `fd --version` | 1 | `fd 10.5.0` | verified |
| sd | `sd --version` | 1 | `sd 1.0.0` | verified |
| bat | `bat --version` | 1 | `bat 0.26.1` | verified |
| eza | `eza --version` | 2 | `v0.23.5 [+git]` | verified |
| jq | `jq --version` | 1 | `jq-1.7.1-apple` | verified |
| yq | `yq --version` | 1 | `yq (https://github.com/mikefarah/yq/) version v4.54.1` | verified |
| delta | `delta --version` | 1 | `delta 0.20.1` | verified |
| hyperfine | `hyperfine --version` | 1 | `hyperfine 2.0.0` | verified |
| dust | `dust --version` | 1 | `Dust 1.2.7` | verified |
| xh | `xh --version` | 1 | `xh 0.26.3` | verified |
| grep | `grep --version` | 1 | `grep (BSD grep, GNU compatible) 2.6.0-FreeBSD` | verified |
| procs | `procs --version` | 1 | `procs 0.14.12` | 未検証 (output depends on the running processes) |
| duf | `duf -version` | 1 | — | 未検証 (output depends on the machine's mounts) |
| fzf | `fzf --version` | 1 | `0.74.5 (Homebrew)` | verified |
| gping | `gping --version` | 1 | `gping 1.21.0` | 未検証 (interactive, network) |
| zoxide | — | — | — | 未検証 (not installed) |
| tldr | — | — | — | 未検証 (not installed) |
| btop | — | — | — | 未検証 (not installed, interactive) |
