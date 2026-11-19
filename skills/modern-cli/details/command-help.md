# Quick command examples: tldr

## Intent

See a few common, worked examples of a command in a short page, instead of reading its full
manual.

## Classic and modern

| classic | modern |
|---|---|
| `man tar` | `tldr tar` |
| `tar --help` | `tldr tar` |
| `man -k keyword` | `tldr --search keyword` (tlrc; names the pages that contain the word, not the manual sections); `apropos` for the manuals |

## Commands

`tldr tar` shows the examples for a command. `tldr --update` (`-u`) refreshes the local cache of
pages, and `tldr --platform linux sed` picks the platform of the page when the command differs per
operating system (`ls`, `ps`, `sed`); tlrc then lists the pages that exist for other platforms.
The text of the pages comes from the community project and is downloaded into a cache on first
use, so no example can check what a real page says; the examples below check what does not depend
on it.

The client is tlrc 1.13.1, the official client. A tldr page is Markdown with a fixed shape (a `#`
title, `>` description lines, `-` lines for what an example does, and the command in backticks),
and `--render` shows a local file the way a page is shown. `--compact` strips the empty lines, and
`{{name}}` marks a placeholder that is shown as plain `name`:

```sh
printf '# demo\n\n> A demo page.\n\n- Say hello:\n\n`echo {{name}}`\n' > demo.md
tldr --compact --render demo.md
```
```text
  demo
  A demo page.
  Say hello:
    echo name
```

With `--offline` the client never downloads. On first use there is no cache, so it fails with
status 4 instead of showing a page:

```sh
tldr --offline tar 2>&1
echo "exit $?"
```
```text
error: cache does not exist. Run tldr without --offline to download pages.
exit 4
```

The options differ between clients. tlrc searches pages with `--search`, and has `--update`,
`--platform`, `--offline` and `--render`:

```sh
tldr --help | grep -E -- "--(search|update|platform|offline|render)"
```
```text
  -u, --update                    Update the cache
  -s, --search <KEYWORD>          Search for pages containing a keyword
  -r, --render <FILE>             Render the specified tldr page
  -p, --platform <PLATFORM>       Specify the platform to use (linux, osx, windows, etc.)
  -o, --offline                   Do not update the cache, even if it is stale
```

## Differences that change results

- **Examples, not reference.** A tldr page lists the common uses; it does not list every option
  or the exact behaviour. `man` is the authoritative description.
- **Community written.** The pages are maintained by a community project and can be incomplete or
  out of date for a given version of the tool; `man` ships with the installed version.
- **Many clients.** `tldr` is a command implemented by several programs. Their options and cache
  behaviour differ, so a flag that works with one may not exist in another.
- **Cache and network.** tlrc keeps a local copy of the pages. With an empty cache it downloads
  them on the first run (about 7600 pages on the checking machine), and it updates the cache
  by itself when it is older than `max_age` (336 hours by default), unless `--offline` is given
  or `auto_update` is false. A machine without network and without a cache shows nothing.
- **Search is not `man -k`.** `tldr --list` lists the pages of the platform (and `--list-all`
  all of them); `tldr --search keyword` finds pages whose text contains the word. Neither
  searches the manual pages of the installed tools.
- **Platform.** Pages are grouped by operating system (common, linux, osx, and so on); the page shown
  may describe the GNU or the BSD form of a command.

## When to keep the classic command

- When the exact option, the exit status or a rarely used behaviour matters: `man`.
- On servers and in containers without tldr, and offline, where `man` and `--help` are present.
- When the page must match the installed version of the tool: `tool --help` or `man`.

## Pitfalls

Copying an example from a tldr page onto a different platform may use the wrong form of a flag
(GNU or BSD). For `sed`, tlrc shows the page of the current platform (`osx` on the checking
machine) and warns that pages exist for `common`, `freebsd`, `linux`, `netbsd` and `openbsd`;
`tldr --platform linux sed` shows the GNU one. Check which platform the page is for, then
confirm the flag with the local manual (`man sed`) before relying on it.

A file that does not follow the page shape is an error, not a page: `tldr --render README.md` on
a Markdown file that is not a page shows the lines before the broken one, then stops with
`is not a valid tldr page`, the line number and the rule (status 5).

## Sources

- `28aedb413b85f86f` tldr-pages
- `74e831fd938988b8` POSIX.1-2024 Shell and Utilities: utilities
