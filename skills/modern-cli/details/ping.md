# Watch latency: gping

## Intent

Watch how the round-trip time to one or more hosts changes, as a graph on the terminal, or graph
how long a command takes on each run, and know that the graph is for a person at a terminal, not
for a script.

## Classic and modern

| classic | modern |
|---|---|
| `ping HOST` | `gping HOST` |
| `ping HOST1` and `ping HOST2` in two terminals | `gping HOST1 HOST2` (one graph, one line per host) |
| `while :; do time CMD; sleep 0.5; done` | `gping --cmd 'CMD'` |
| `ping -c 5 -q HOST` (a summary to read or parse) | no equivalent: keep `ping` |

## Commands

gping draws on the terminal and runs until you press `q` or `Esc`, so its graph cannot be shown
here. Two runs that need no terminal show how it behaves for a script: without a terminal it draws
nothing and exits 1 (its message, `Device not configured` on macOS, goes to standard error), and
the same holds for `--cmd`:

```sh
# spec: CLI-GPING-01 CLI-GPING-04
gping 127.0.0.1 2>/dev/null; echo "gping exit $?"
gping --cmd true 2>/dev/null; echo "gping --cmd exit $?"
```
```text
gping exit 1
gping --cmd exit 1
```

Its options are about the graph: how often to measure (`-n`, seconds), how many seconds the graph
holds (`-b`) and `--cmd` to time commands instead of pinging. There is no option to stop after a
number of probes (the last `grep -c` counts 0 and so exits 1):

```sh
# spec: CLI-GPING-02 CLI-GPING-03
# exit: 1
gping --help | head -n 1
gping --help | grep -E '^ +(--cmd|-n, --watch-interval|-b, --buffer)'
gping --help | grep -c -e '--count'
```
```text
Ping, but with a graph.
      --cmd
  -n, --watch-interval <WATCH_INTERVAL>
  -b, --buffer <BUFFER>
0
```

With no host and no command it prints a usage error and exits 1, like the terminal case, so a
script cannot tell the two apart by the status:

```sh
# spec: CLI-GPING-06
gping > /dev/null 2>&1; echo "exit $?"
```
```text
exit 1
```

For a script, `ping -c N` stops after N probes, and `-q` prints only the summary. The loopback
address answers without a network. The summary line is the BSD (macOS) form; GNU `ping` writes
`2 received, 0% packet loss, time …`:

```sh
# spec: CLI-GPING-02 CLI-GPING-04
ping -c 2 -q 127.0.0.1 | grep 'packets transmitted'; echo "ping exit $?"
```
```text
2 packets transmitted, 2 packets received, 0.0% packet loss
ping exit 0
```

A script that writes `down` for any non-zero status also reports its own mistakes as `down`. On
macOS `ping` exits 2 when no reply came, 64 on a usage error and 68 when the host name does not
resolve; GNU `ping` exits 1 when no reply came and 2 on other errors. A script for one platform
tests for its no-reply status and treats the others as a failure of the check. A script for both
cannot tell the two apart by the status (2 means no reply on macOS and an error with GNU): treat
0 as up and anything else as down, and keep ping's standard error and status in the log so an
error is visible:

```sh
# spec: CLI-GPING-12
ping -c 1 -Z 127.0.0.1 > /dev/null 2>&1; echo "bad option: $?"
ping -c 1 127.0.0.1 > /dev/null 2>&1; echo "reply: $?"
```
```text
bad option: 64
reply: 0
```

## Differences that change results

- **Needs a terminal.** gping draws a full-screen graph; without a terminal (a pipe, cron, CI, an
  agent's shell) it draws nothing and exits 1.
- **No count.** gping runs until `q` or `Esc`; `ping -c N` stops after N probes and prints a
  summary.
- **Graph options.** `-n` sets the interval in seconds, `-b` the seconds the graph holds, and
  `--cmd` times commands instead of pinging; several hosts share one graph.
- **No output for programs.** gping prints nothing a program can read; parse `ping -q`'s summary,
  whose wording differs between BSD and GNU.
- **Status.** gping exits 1 both without a terminal and on a usage error. `ping` exits 0 when a reply
  arrived; on macOS 2 when none did, 64 on a usage error and 68 for a name that does not resolve;
  GNU `ping` 1 when none did and 2 on other errors.
- **Version.** The examples were checked with `gping 1.21.0`.

## When to keep the classic command

- Scripts, health checks and CI: use `ping -c N` and its status, or a tool made for monitoring.
- Measuring packet loss or a summary to keep: `ping -c N -q` prints it; gping shows only a graph.
- Hosts without gping: `ping` is on every system.

## Pitfalls

Running gping where nothing can show the graph (from a script or an agent) fails at once and
reports nothing useful on standard output. Ask `ping` for a fixed number of probes instead:

```sh bad
gping 127.0.0.1 > latency.txt
```
```sh
ping -c 1 -q 127.0.0.1 | grep -c 'packets transmitted'
```
```text
1
```

## Sources

- `2b368f6cc6199a66` gping
- `e03dc24f71cd5825` ping(8), Ubuntu 24.04 manual page
