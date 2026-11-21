# Spec table: remote

One row per claim of the sections "Differences that change results" (D) and "When to keep the classic command" (K) of `skills/modern-cli/details/remote.md`. 例 = an example of the page names the ID in a `# spec:` line; 本文のみ = no example does, for the category and reason given (MCLI-SPEC-02).

| ID | 箇所 | 主張 | 確かめ |
|---|---|---|---|
| CLI-SSH-01 | D1 | The first value found wins in the configuration file, so `Host *` goes last; `ssh -G HOST` shows the result without connecting | 例 |
| CLI-SSH-02 | D2 | The command line beats the file: `-p`, `-l`, `user@host`, `-o` override the file; `-F` replaces the configuration files | 例 |
| CLI-SSH-03 | D3 | `-G` shows the configuration, not whether the network, host key or login works | 本文のみ (通信: needs a connection to check a login) |
| CLI-SSH-04 | D4 | The default `stricthostkeychecking ask` asks to confirm an unknown host key, and `-o BatchMode=yes` makes `ssh` fail rather than ask | 本文のみ (通信: the first connection to a host is needed) |
| CLI-SSH-05 | D5 | `ssh HOST CMD` returns the status of `CMD` | 本文のみ (通信: needs a connection) |
| CLI-SSH-06 | D6 | `ssh HOST 'echo $HOME'` expands `$HOME` on the remote host and the double-quoted form expands it locally | 本文のみ (通信: needs a remote shell) |
| CLI-SSH-07 | D7 | Recent OpenSSH carries `scp` over SFTP, `-O` selects the old protocol, and `scp -r` replaces files without asking and copies everything | 本文のみ (通信: needs a server) |
| CLI-SSH-08 | D8 | `ssh-keygen` writes the private key readable by its owner only, `ssh` refuses a key readable by others, `-N ''` leaves no passphrase, and an existing key is not overwritten without a yes | 例 |
| CLI-SSH-09 | D9 | The fingerprint of a new key is random and only the size and type are repeatable | 例 |
| CLI-SSH-10 | K1 | In a script use `-o BatchMode=yes`, quote the remote command and check for status 255 | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-SSH-11 | K2 | Use `rsync -e ssh` to copy a tree and `tar -cf - DIR \| ssh HOST 'tar -xf - -C DEST'` to stream a directory | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-SSH-12 | K3 | Use `xh` to call an HTTP API on a host | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-SSH-13 | K4 | Debug with `ssh -v HOST` for the steps and `ssh -G HOST` for the configuration | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-SSH-14 | D5 | `ssh` exits 255 when it fails itself, for example on an unreadable `-F` file | 例 |
