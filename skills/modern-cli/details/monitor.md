# Watch system load live: btop

Status: 未検証 (not installed, interactive)

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

Start the monitor. It takes over the terminal until you quit it (`q` or Esc, then confirm):

```sh unverified
btop
```

Start with a low-colour terminal setting, for terminals that cannot show the default theme (see
`btop --help` for the options of the installed version):

```sh unverified
btop --low-color
```

## Differences that change results

- **Interactive only.** btop draws a full-screen interface and reads the keyboard. It has no mode
  that prints one table and exits, so it cannot be piped or used in cron.
- **More than processes.** It shows CPU cores, memory, disks and network at once; `top` shows a
  summary and processes.
- **Mouse and menus.** btop can be used with the mouse and an options menu, and keeps its
  settings in a configuration file, so two machines can look different.
- **Sorting and filtering.** Done with keys inside the interface; `top` takes `-o` and `-n` on the
  command line.
- **Platform.** `top` flags differ between BSD and GNU; btop has the same interface on both.

## When to keep the classic command

- Scripts, logs and one-shot snapshots: `top -l 1` (BSD) or `top -b -n 1` (GNU) print once and
  exit; `ps` gives a parseable table.
- Servers, containers and rescue shells where btop is not installed.
- Narrow or slow terminals (a serial console) where a full-screen interface is not usable.

## Pitfalls

btop needs a terminal. Started without one (cron, CI, a pipe), it cannot draw its interface. For
a snapshot in a script, use a command that prints and exits:

```sh unverified
top -l 1 -n 5
```

## Sources

- `d5113d31cfbb193d` btop
- `e372d8114adfc35f` The Linux Command Line
