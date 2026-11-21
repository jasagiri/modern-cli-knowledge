# Create, list and extract archives: tar

## Intent

Pack a directory into one file, look inside it, and unpack it where you want, with `tar` and its
compression flags, knowing how the paths stored in the archive decide where the files land and
where BSD tar (the `tar` of macOS, `bsdtar`) differs from GNU tar.

## Classic and modern

| classic | modern |
|---|---|
| `tar -cf`, `tar -tf`, `tar -xf`, with `-z` `-j` `-J` | none (keep the classic tool) |

## Commands

The `tar` on the checking machine is `bsdtar` (libarchive); GNU tar is the `tar` of most Linux
systems, and the examples use only options that both accept. The first letter chooses the mode:
`-c` create, `-t` list, `-x` extract, and `-f FILE` names the archive (`-f -` is standard input or
output). The order in which `tar -t` prints the members is the order in which they were stored, which
follows the directory order of the filesystem, so the examples sort it:

```sh
# spec: CLI-TAR-01
tar --version | cut -c1-6
tar -cf a.tar notes
tar -tf a.tar | sort
```
```text
bsdtar
notes/
notes/meeting notes.txt
notes/todo.txt
notes/日本語.txt
```

A member keeps the path it was given on the command line, so `tar -cf a.tar notes` stores
`notes/...` and unpacks as a directory `notes`. `-C DIR` changes the directory before the names that
follow it: `-C notes .` stores the contents of `notes` as `./...`, without the directory itself.
When extracting, `-C DIR` is where the files go (the directory must exist, otherwise `tar` fails
with status 1):

```sh
# spec: CLI-TAR-02 CLI-TAR-09
tar -cf a.tar -C notes .
tar -tf a.tar | sort
mkdir out
tar -xf a.tar -C out
ls out
tar -xf a.tar -C nodir 2>/dev/null; echo "status: $?"
tar -cf b.tar notes -C src .
tar -tf b.tar | grep -c '^\./'
tar -tf b.tar | grep -c '^notes/'
```
```text
./
./meeting notes.txt
./todo.txt
./日本語.txt
meeting notes.txt
todo.txt
日本語.txt
status: 1
4
4
```

An absolute path loses its leading `/` when it is stored, so unpacking never writes outside the
current directory by that route (a warning goes to standard error). `--strip-components=N` drops N
leading directories from each member when extracting:

```sh
# spec: CLI-TAR-03
tar -cf a.tar /etc/hosts 2>/dev/null
tar -tf a.tar
tar -cf b.tar notes
mkdir o
tar -xf b.tar --strip-components=1 -C o
ls o
```
```text
etc/hosts
meeting notes.txt
todo.txt
日本語.txt
```

`-z` compresses with gzip, `-j` with bzip2 and `-J` with xz when creating. When reading, bsdtar and
GNU tar detect the compression themselves, so `-xf` and `-tf` need no flag. The same archive can be
made with a pipe, which is the portable form for any compressor:

```sh
# spec: CLI-TAR-04
tar -czf a.tgz notes
tar -tf a.tgz | sort | head -n 2
tar -cf - notes | gzip > b.tgz
gzip -dc b.tgz | tar -tf - | wc -l | tr -d ' '
tar -cjf a.tbz notes; tar -cJf a.txz notes
tar -tf a.txz | wc -l | tr -d ' '
```
```text
notes/
notes/meeting notes.txt
4
4
```

Names after the archive restrict the mode to those members. `-O` writes the content of the extracted
members to standard output instead of to files, so one file can be read without unpacking:

```sh
# spec: CLI-TAR-05
tar -cf a.tar notes
mkdir o
tar -xf a.tar -C o notes/todo.txt
find o -type f
tar -xOf a.tar notes/todo.txt | head -n 1
tar -xf a.tar -C o notes/nope 2>/dev/null; echo "status: $?"
```
```text
o/notes/todo.txt
TODO: buy milk
status: 1
```

Extraction overwrites an existing file without asking. `-k` keeps the existing files:

```sh
# spec: CLI-TAR-06
tar -cf a.tar -C notes todo.txt
mkdir o; echo old > o/todo.txt
tar -xf a.tar -C o; head -n 1 o/todo.txt
echo old > o/todo.txt
tar -xkf a.tar -C o; head -n 1 o/todo.txt
```
```text
TODO: buy milk
old
```

`--exclude=PATTERN` leaves out the members that match (the pattern is a shell pattern, quoted so the
shell does not expand it). `-v` lists each member as it is processed; bsdtar writes that list to
standard error, so it is not in a pipe on standard output (GNU tar writes it to standard output
when creating):

```sh
# spec: CLI-TAR-08
tar -cf a.tar --exclude='*.txt' notes
tar -tf a.tar
tar -cvf b.tar notes 2>/dev/null | wc -l | tr -d ' '
tar -cvf b.tar notes 2>&1 >/dev/null | wc -l | tr -d ' '
```
```text
notes/
0
4
```

## Differences that change results

- **BSD tar versus GNU tar.** The `tar` of macOS is `bsdtar` (`tar --version` starts with `bsdtar`),
  the `tar` of most Linux systems is GNU tar, and the two accept different long options. Stay with
  `-c -t -x -f -C -v -z -j -J -k` and `--exclude`, which both accept.
- **The stored path decides where files land.** `tar -cf a.tar notes` unpacks as `notes/...`,
  `tar -cf a.tar -C notes .` unpacks its files directly into the extraction directory (a "tar
  bomb" when extracted in a directory that holds other files). List with `tar -tf` before extracting
  an archive from someone else, and extract with `-C DIR`.
- **Absolute paths.** A leading `/` is removed on creation (with a warning on standard error), so
  an archive of `/etc/hosts` unpacks as `etc/hosts`. Check the listing of an archive from someone else before extracting it.
- **`-C` applies to what follows.** In `tar -cf b.tar notes -C src .` the `-C` affects only the
  names after it. With `-x`, `-C DIR` fails with status 1 when `DIR` does not exist; it does not
  create it.
- **Compression flags.** `-z`, `-j` and `-J` select the compressor when creating, and bsdtar detects
  the format when reading, even with a wrong flag (bsdtar's `-xzf` on an uncompressed archive
  works); GNU tar's `-z` on input that is not gzip fails. A flag-free `-xf` is correct for both.
- **Overwriting.** Extraction replaces existing files without asking; `-k` keeps them.
- **Order.** `tar -t` prints members in the order stored, which is the directory order of the
  filesystem when the archive was made, so the same tree can list differently on two machines; sort
  it before comparing.
- **`-v` goes to different streams.** bsdtar writes the member list of `-v` to standard error,
  GNU tar to standard output when creating (and for `-t`, the listing itself is the output), which
  matters in a pipe.
- **Status.** A missing member or a missing `-C` directory gives status 1 after the other members
  were processed (`Error exit delayed from previous errors`), so a failure is not always the first
  message.

## When to keep the classic command

- `tar` is the tool: there is nothing to replace it with here. In a POSIX script or an image
  without the options of your tar, use the pipe form: `tar -cf - DIR | gzip > OUT.tgz` and
  `gzip -dc OUT.tgz | tar -xf -`, which need no `-z`.
- For `.zip` files, which are a different format, use `zip -r` to create, `unzip -Z1 FILE` to list
  the names and `unzip -d DIR FILE` to extract.
- For one file, `gzip -k FILE` compresses and keeps the original, and `gzip -dc` writes the
  uncompressed content to standard output; no archive is needed.
- To copy a tree again and again, or to a machine over a network, `rsync` copies only what changed
  and needs no intermediate archive; to keep versions of files, use `jj` (`version-control.md`).

## Pitfalls

An archive built from `-C DIR .` has no top-level directory, so extracting it in the current
directory scatters its files next to yours. Look first with `tar -tf`, then extract into a directory
of its own:

```sh bad
tar -xf a.tar
```
```sh
# spec: CLI-TAR-02
tar -cf a.tar -C notes .
tar -tf a.tar | sort | head -n 2
mkdir out
tar -xf a.tar -C out
ls out
```
```text
./
./meeting notes.txt
meeting notes.txt
todo.txt
日本語.txt
```

## Sources

- `e3baeb3cde5e4420` tar(1), Ubuntu 24.04 manual page
