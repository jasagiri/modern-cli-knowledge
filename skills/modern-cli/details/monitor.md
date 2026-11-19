# Watch system load live: btop

## Intent

Watch CPU, memory, disks, network and processes on one live screen, and act on a process (filter,
sort, send a signal) with the keyboard.

## Classic and modern

| classic | modern |
|---|---|
| `top` | `btop` |
| `top -o cpu` (BSD), `top -o %CPU` (GNU) | sort by CPU inside btop |
| `vm_stat`, `iostat`, `netstat -i` | the memory, disk and network panels of btop |

## Commands

`btop` starts the monitor. It takes over the terminal until you quit it, so no example can show
its screen. Inside it the keyboard acts: `q` quits at once (status 0), and `Esc` opens the main
menu, whose third entry (two Down keys and Enter) is Quit; both were checked in a terminal
multiplexer session, not by an example. Options start it in another state: `--low-color` (`-l`) disables true
colour and uses 256 colours only, `--tty` (`-t`) forces tty mode with ANSI graph symbols and 16
colours, `--filter` (`-f`) sets an initial process filter, `--preset` (`-p`) starts with a preset
(0-9), and `--update` (`-u`) sets the update rate in milliseconds. These are the options of the
installed 1.4.8:

```sh
# spec: CLI-BTOP-04
btop --help | grep -o -e "--low-color" -e "--tty" -e "--filter" -e "--preset" -e "--default-config"
```
```text
--filter
--low-color
--preset
--tty
--default-config
```

The settings live in a configuration file, which is why two machines can look different.
`--default-config` prints the default one to standard output (the first line names the version):

```sh
# spec: CLI-BTOP-03
btop --default-config | sed -n 1p
```
```text
#? Config file for btop v.1.4.8
```

Without a terminal (cron, CI, a pipe) btop does not draw. It reports that there is no tty and
ends with status 1; the output holds colour codes, so the example only counts the lines that say
so:

```sh
# spec: CLI-BTOP-01
btop 2>&1 | grep -c "No tty detected"
btop >/dev/null 2>&1
echo "exit $?"
```
```text
1
exit 1
```

## Differences that change results

- **Interactive only.** btop draws a full-screen interface and reads the keyboard. It has no mode
  that prints one table and exits, so it cannot be piped or used in cron.
- **More than processes.** It shows CPU cores, memory, disks and network at once; `top` shows a
  summary and processes.
- **Mouse and menus.** btop can be used with the mouse and an options menu, and keeps its
  settings in a configuration file, so two machines can look different.
- **Sorting and filtering.** Done with keys inside the interface (a start-up filter can be given
  with `--filter`); `top` takes `-o` and `-n` on the command line.
- **Platform.** `top` flags differ between BSD and GNU; btop has the same interface on both.

## When to keep the classic command

- Scripts, logs and one-shot snapshots: `top -l 2` (BSD) or `top -b -n 1` (GNU) print and exit; `ps` gives a parseable table.
- Servers, containers and rescue shells where btop is not installed.
- Narrow or slow terminals (a serial console) where a full-screen interface is not usable.

## Pitfalls

btop needs a terminal, as shown above. For a snapshot in a script, use a command that prints and
exits. `top -l 2 -n 5` is for BSD and macOS (`-l` is BSD only; the CPU figures of the first
sample are not meaningful, so take the second with `-l 2`), and `top -b -n 1 | head -n 12` is for
GNU `top`, where macOS `top` stops with `invalid option or syntax: -b`. What they print is the
load of the machine, so the examples check only that a snapshot ends by itself:

```sh bad
btop
```
Use the snapshot command of the platform (the first line of the BSD one is `Processes:`):

```sh
# spec: CLI-BTOP-05 CLI-BTOP-06
top -l 1 -n 1 | grep -c "^Processes:"
```
```text
1
```

## Sources

- `d5113d31cfbb193d` btop
- `e372d8114adfc35f` The Linux Command Line
