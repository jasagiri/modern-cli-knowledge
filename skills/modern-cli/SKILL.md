---
name: modern-cli
description: Use modern Unix command-line tools (rg, fd, sd, bat, eza, dust, jq, yq, xh, delta, hyperfine, fzf, jj, gping) instead of grep, find, sed, cat, ls, du, curl, diff, time, git and ping when working interactively in a repository, knowing how their results differ (ignored and hidden files, regex dialect, output order, standard input, in-place editing, exit status) and when the classic POSIX command is still the right one (portable scripts, CI images, servers without the tools).
---

# Modern command-line tools

## First decide: modern or classic?

| situation | use |
|---|---|
| interactive work in a repository on a machine that has the tools | the modern tool |
| a script that others run, a Dockerfile, CI without a setup step, a server you did not provision | the classic POSIX command (`grep`, `find`, `sed`, `awk`, `ls`, `du`, `curl`) |
| you need every file, ignored or hidden ones included | classic, or the modern tool with its "search everything" flags (`rg -uuu`, `fd -H -I`) |
| the output is parsed by another program | a format meant for programs: `rg --json` (or `rg -H -n`), `fd -0`, `jq -c`, `hyperfine --export-json`, `procs --json`, `duf -json` (it ignores `-only` and paths: filter with jq) |
| the tool is not installed | do not install it as a side effect; use the classic command |
| a repository that already has `.jj` | jj for recording and rewriting changes; git where a script, hook or CI job expects it |

## Tasks

| task | classic | modern | page |
|---|---|---|---|
| search text in files | `grep -rn` | `rg` | [details/search-text.md](details/search-text.md) |
| find files by name | `find` | `fd` | [details/find-files.md](details/find-files.md) |
| replace text in files | `sed -i` | `sd` | [details/replace-text.md](details/replace-text.md) |
| view a file | `cat`, `less` | `bat` | [details/view-files.md](details/view-files.md) |
| list directories | `ls`, `tree` | `eza` | [details/list-dirs.md](details/list-dirs.md) |
| disk usage of a tree | `du` | `dust` | [details/disk-usage.md](details/disk-usage.md) |
| query and reshape JSON | `grep`/`sed` on JSON | `jq` | [details/json.md](details/json.md) |
| read and edit YAML | `grep`/`sed` on YAML | `yq` | [details/yaml.md](details/yaml.md) |
| build HTTP requests | `curl` | `xh` | [details/http.md](details/http.md) |
| read differences | `diff -u` | `delta` | [details/diff.md](details/diff.md) |
| measure run time | `time` | `hyperfine` | [details/benchmark.md](details/benchmark.md) |
| pick from a list | `grep` | `fzf` (`--filter` in scripts) | [details/pick-interactively.md](details/pick-interactively.md) |
| combine them in pipelines | `find -print0 \| xargs -0` | `fd -0 \| xargs -0`, `fd -x`, `rg --json \| jq` | [details/combine.md](details/combine.md) |
| list processes | `ps` | `procs` | [details/processes.md](details/processes.md) |
| free disk space | `df` | `duf` | [details/disk-free.md](details/disk-free.md) |
| jump to a directory | `cd` | `zoxide` | [details/navigate.md](details/navigate.md) |
| short command help | `man` | `tldr` | [details/command-help.md](details/command-help.md) |
| watch system load | `top` | `btop` | [details/monitor.md](details/monitor.md) |
| record and rewrite changes | `git` | `jj` | [details/version-control.md](details/version-control.md) |
| watch latency to hosts | `ping` | `gping` | [details/ping.md](details/ping.md) |

Every page's examples are run by the tests. Commands whose output depends on the machine, the
network or a terminal (the process table of `procs`, the tables of `duf`, the screens of `btop` and `gping`,
`z` changing the directory of a shell, the pages of `tldr`) are described in the text, not run;
the examples beside them check what does not depend on those. A page that cannot run any command
would carry a `Status: 未検証 (<reason>)` line; none does now.

## Differences that silently change results

- **Ignored and hidden files.** rg and fd skip what `.gitignore` lists (inside a repository) and
  hidden files; grep and find do not. A search that "finds nothing" may only be skipping.
- **Order.** rg and fd work in parallel: their output order changes between runs. Sort explicitly
  when order matters: `rg --sort path` sorts within each path argument (arguments stay in the order
  given), so for several paths pipe to `sort` (`rg -H -n PAT a b | LC_ALL=C sort -t: -k1,1 -k2,2n`);
  `fd … | sort`.
- **Standard input.** rg, eza and xh read standard input when it is not a terminal and no path or
  body is given (cron, CI, `xargs`, pipelines). Name the path (`rg TODO .`, `eza .`) and use
  `xh --ignore-stdin`.
- **Regex dialect.** rg and sd use Rust regex: `(` groups, `$1` in replacements, no
  backreferences. Use `-F` for literal text.
- **In-place editing.** `sd PATTERN REPL FILE` edits the file; BSD `sed -i ''` and GNU `sed -i`
  differ. `jq` never edits in place; `yq -i` does.
- **Output when piped.** Several tools change format when not on a terminal: rg drops line numbers
  (and the file name for a single file) unless `-H -n`, bat becomes plain, eza prints one name per
  line; delta keeps colour codes even with `NO_COLOR`.
- **Exit status.** rg exits 1 on no match, fd exits 0; `jq -e` and `yq -e` turn `null` or `false`
  into exit 1. Check what a script tests.

## When you write a command for someone else

Write the classic command when you do not know the target machine has the tool, and say so when
you use a modern one in a script. Never pipe a modern tool's decorated output into another
program; ask for its plain or machine format. In a CI check, branch on the output, not on the
status, after checking that `src` exists (a missing directory also gives empty output), because
grep's "no match" (1) and a real error look the same to `find`. Copy the CI check from
`details/combine.md` ("When to keep the classic command", the block with `[ $? -le 1 ]`): it
exits 1 on hits, 0 when clean and 2 when grep fails, and was run on BSD and BusyBox.
