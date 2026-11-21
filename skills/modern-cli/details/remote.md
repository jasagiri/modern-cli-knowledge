# Run commands and copy files on other machines: ssh, scp, ssh-keygen

## Intent

Say which host, user, port and key `ssh` will use before connecting, make and inspect a key pair,
and know what `ssh` and `scp` do on the network, with the examples limited to what can be checked
without a connection: the resolved configuration (`ssh -G`) and keys made locally.

## Classic and modern

| classic | modern |
|---|---|
| `ssh`, `scp`, `ssh-keygen` | none (keep the classic tool) |

## Commands

No example connects to anything. `ssh -V` prints the version of OpenSSH (on stderr, hence the
`2>&1`). `ssh -G HOST` prints the configuration `ssh` would use for `HOST`, one option per line in
lower case, and exits without connecting; `-F FILE` reads that file instead of `~/.ssh/config` and
the system file, so the example writes its own. The full output has dozens of lines, so pick the
options with `grep`:

```sh
ssh -V 2>&1 | cut -c1-8
printf 'Host web\n  HostName 192.0.2.10\n  User deploy\n  Port 2222\n' > cfg
ssh -F cfg -G web 2>/dev/null | grep -E '^(hostname|user|port) '
```
```text
OpenSSH_
user deploy
hostname 192.0.2.10
port 2222
```

For each option the first value found wins, reading the file from the top, so a specific `Host`
block must come before `Host *`. A host that no block names gets the defaults of `Host *`, and its
own name as `hostname`:

```sh
# spec: CLI-SSH-01
printf 'Host web\n  HostName 192.0.2.10\n  Port 2222\nHost *\n  Port 22\n  User anon\n' > cfg
ssh -F cfg -G web 2>/dev/null | grep -E '^(hostname|user|port) '
echo --
ssh -F cfg -G other 2>/dev/null | grep -E '^(hostname|user|port) '
echo --
printf 'Host *\n  Port 22\nHost web\n  Port 2222\n' > cfg2
ssh -F cfg2 -G web 2>/dev/null | grep -E '^port '
```
```text
user anon
hostname 192.0.2.10
port 2222
--
user anon
hostname other
port 22
--
port 22
```

Options on the command line beat the file: `-p` the port, `-l` or `user@host` the user, `-o Key=Value` any
option. `-o BatchMode=yes` makes `ssh` fail instead of asking a question, which is what a script wants
(the default `batchmode no` is what `-G` shows):

```sh
# spec: CLI-SSH-02
printf 'Host web\n  HostName 192.0.2.10\n  Port 2222\n' > cfg
ssh -F cfg -p 99 -G web 2>/dev/null | grep -E '^port '
ssh -F cfg -o Port=77 -G web 2>/dev/null | grep -E '^port '
ssh -F cfg -G bob@web 2>/dev/null | grep -E '^(user|hostname) '
ssh -F cfg -G web 2>/dev/null | grep -E '^batchmode '
ssh -F cfg -o BatchMode=yes -G web 2>/dev/null | grep -E '^batchmode '
```
```text
port 99
port 77
user bob
hostname 192.0.2.10
batchmode no
batchmode yes
```

A file that cannot be read is an error with status 255, the status `ssh` uses for its own failures
(the status of the remote command is returned otherwise):

```sh
# spec: CLI-SSH-14
# exit: 255
ssh -F nofile -G web
```
```text
```

`ssh-keygen -t ed25519 -N '' -f k -q` makes a key pair without a passphrase (`-N ''`), without
questions (`-q`): the private key `k`, readable only by its owner, and the public key `k.pub`.
The public file starts with the key type. The fingerprint of a new key is random, so the example
prints only the shape of `-l`: the size and type, and the prefix of the hash name:

```sh
# spec: CLI-SSH-08 CLI-SSH-09
ssh-keygen -t ed25519 -N '' -f k -q
ls k k.pub
ls -l k | cut -c1-10
cut -d' ' -f1 k.pub
ssh-keygen -l -f k | awk '{print $1, $NF}'
ssh-keygen -l -f k.pub | awk '{print substr($2, 1, 7)}'
```
```text
k
k.pub
-rw-------
ssh-ed25519
256 (ED25519)
SHA256:
```

`-l -f` reads the private or the public file and prints `BITS FINGERPRINT COMMENT (TYPE)`. `-C`
sets the comment, which is the last field of the public file. `-t rsa -b 3072` makes an RSA key of
that size. `ssh-keygen` does not overwrite an existing key: it asks on standard output, and with
no answer it stops with status 1:

```sh
# spec: CLI-SSH-08
ssh-keygen -t ed25519 -N '' -f k -q -C me@example
cut -d' ' -f3 k.pub
ssh-keygen -l -f k | awk '{print $3}'
ssh-keygen -t ed25519 -N '' -f k -q < /dev/null; echo "status: $?"
ssh-keygen -t rsa -b 3072 -N '' -f r -q
ssh-keygen -l -f r | awk '{print $1, $NF}'
```
```text
me@example
me@example
k already exists.
Overwrite (y/n)? status: 1
3072 (RSA)
```

A file that is not a key is an error with status 255:

```sh
# exit: 255
echo garbage > bad
ssh-keygen -l -f bad
```
```text
```

## Differences that change results

- **First value wins.** In `~/.ssh/config`, for each option the first value `ssh` finds is used,
  so `Host *` belongs at the end; a catch-all at the top overrides every later block. Check with
  `ssh -G HOST`, which shows the result without connecting.
- **The command line beats the file.** `-p`, `-l`, `user@host` and `-o` override the
  configuration, and `-F FILE` replaces the configuration files altogether.
- **`-G` shows the configuration, not the connection.** It does not test the network, the host key
  or the login. Whether a key is accepted is known only by connecting (`ssh -v HOST` shows the
  steps).
- **The first connection asks.** The default `stricthostkeychecking ask` asks to confirm an
  unknown host key and a script cannot answer; `-o BatchMode=yes` makes `ssh` fail rather than
  ask. Do not turn host key checking off to silence this: it removes the protection against a
  host that pretends to be another.
- **`ssh` returns the remote status.** The exit status of `ssh HOST CMD` is that of `CMD`, and 255
  when `ssh` itself failed (connection, authentication, an unreadable `-F` file), so 255 is not
  a status of the remote command.
- **Quoting happens twice.** The remote command is passed as a string to the remote shell:
  `ssh HOST 'echo $HOME'` expands `$HOME` there, `ssh HOST "echo $HOME"` expands it here before
  `ssh` starts. Quote for the remote shell as for a command in a script.
- **`scp` and its protocol.** `scp HOST:PATH DEST` copies over SSH; recent OpenSSH carries it over
  the SFTP protocol, where older versions used a separate one, so remote `~` and wildcards are
  expanded differently; `-O` selects the old one. For trees, `scp -r` replaces files without asking
  and does not copy only the changes.
- **Keys.** `ssh-keygen` writes the private key readable by its owner only, and `ssh` refuses a
  private key whose file is readable by others. `-N ''` leaves the key without a passphrase, so
  whoever copies the file can use it. An existing key is not overwritten without a yes.
- **The fingerprint is random.** The fingerprint of a new key differs every time; only the size and
  the type are repeatable, so compare fingerprints, not their shape, to check a key.

## When to keep the classic command

- `ssh`, `scp` and `ssh-keygen` are the tools: there is nothing to replace them with here, and they
  are on every server. In a script use `-o BatchMode=yes`, quote the remote command, and check for
  status 255 apart from the remote command's own.
- To copy a tree, or to repeat a copy and send only the changes, use `rsync -e ssh` rather than
  `scp -r`; to send a directory as a stream, `tar -cf - DIR | ssh HOST 'tar -xf - -C DEST'`
  (`archives.md`).
- To call an HTTP API on a host, use `xh` (`http.md`) rather than tunnelling `curl` through `ssh`.
- To debug a connection, `ssh -v HOST` for the steps and `ssh -G HOST` for the configuration; read
  the configuration first, the network second.

## Pitfalls

A `Host *` block at the top fixes the port and the user for every host, and the specific block
below it is never consulted, because the first value wins. Put the catch-all last and check with
`ssh -G`:

```sh bad
printf 'Host *\n  Port 22\nHost web\n  Port 2222\n' > cfg
```
```sh
# spec: CLI-SSH-01
printf 'Host web\n  Port 2222\nHost *\n  Port 22\n' > cfg
ssh -F cfg -G web 2>/dev/null | grep -E '^port '
```
```text
port 2222
```

## Sources

- `7875e4c6a7743127` ssh(1), Ubuntu 24.04 manual page
- `8925b62002c66cbf` scp(1), Ubuntu 24.04 manual page
- `dc3b74a1467cedb1` ssh-keygen(1), Ubuntu 24.04 manual page
