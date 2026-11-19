# Quick command examples: tldr

Status: 未検証 (not installed)

## Intent

See a few common, worked examples of a command in a short page, instead of reading its full
manual.

## Classic and modern

| classic | modern |
|---|---|
| `man tar` | `tldr tar` |
| `tar --help` | `tldr tar` |
| `man -k keyword` | `tldr --list` (all pages) |

## Commands

Show the examples for a command:

```sh unverified
tldr tar
```

Update the local cache of pages, for clients that keep one (the options differ between clients,
see the client's own help):

```sh unverified
tldr --update
```

Pick the platform of the page, when the command differs per operating system (`ls`, `ps`, `sed`):

```sh unverified
tldr --platform linux ps
```

## Differences that change results

- **Examples, not reference.** A tldr page lists the common uses; it does not list every option
  or the exact behaviour. `man` is the authoritative description.
- **Community written.** The pages are maintained by a community project and can be incomplete or
  out of date for a given version of the tool; `man` ships with the installed version.
- **Many clients.** `tldr` is a command implemented by several programs. Their options and cache
  behaviour differ, so a flag that works with one may not exist in another.
- **Cache and network.** The client keeps a local copy of the pages, which may need an update or be
  empty on first use.
- **Platform.** Pages are grouped by operating system (common, linux, osx, and so on); the page shown
  may describe the GNU or the BSD form of a command.

## When to keep the classic command

- When the exact option, the exit status or a rarely used behaviour matters: `man`.
- On servers and in containers without tldr, and offline, where `man` and `--help` are present.
- When the page must match the installed version of the tool: `tool --help` or `man`.

## Pitfalls

Copying an example from a tldr page onto a different platform may use the wrong form of a flag
(GNU or BSD). Check the platform of the page, then confirm with the local manual:

```sh unverified
tldr --platform osx sed
man sed
```

## Sources

- `28aedb413b85f86f` tldr-pages
- `74e831fd938988b8` POSIX.1-2024 Shell and Utilities: utilities
