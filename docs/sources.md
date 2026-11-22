# Sources and their licences

The catalog holds only these 41 sources (ADR-MCLI-0004): each modern tool's own documentation,
and for the classic commands the GNU manuals, the Git reference manual, the Ubuntu 24.04 manual
pages at manpages.ubuntu.com and one Wikipedia article (on signals). Their licences were read on 2026-11-22 and are written as SPDX
identifiers in `catalog/config.json`:

- a tool's repository: the licence files at its root (a dual licence lists both);
- jq: the notice on the manual (code MIT, documentation CC BY 3.0);
- the GNU manuals: the permission notice in each manual (GFDL 1.3 or later, no invariant sections);
- the Git manual: the project's COPYING (GPL version 2 only);
- Wikipedia: the notice at the foot of the article (CC BY-SA 4.0);
- an Ubuntu manual page: the `Files: *` stanza of its package's Debian copyright file, which covers
  the manual page (less is "GPL-3+ or Less"; the GPL is the one listed).

Every licence allows use, copying, modification and distribution for any purpose, commercial use
included (`commercialLicenses` in free-books-catalog's `src/free_books_catalog/licences.nim`;
catalog_build refuses any other because `catalog/config.json` sets `"commercialOnly": true`, and
MCLI-SRC-01 checks the committed catalog). The pages cite these sources by catalog ID and are written
here, not copied from them.

| Source | Catalog ID | Licences |
|---|---|---|
| [apropos(1), Ubuntu 24.04 manual page](https://manpages.ubuntu.com/manpages/noble/man1/apropos.1.html) | `0a013e0613e1a4d9` | GPL-2.0-or-later |
| [bat](https://github.com/sharkdp/bat) | `0236c1696550e790` | MIT, Apache-2.0 |
| [btop](https://github.com/aristocratos/btop) | `d5113d31cfbb193d` | Apache-2.0 |
| [curl(1), Ubuntu 24.04 manual page](https://manpages.ubuntu.com/manpages/noble/man1/curl.1.html) | `327552a164545fd5` | curl |
| [delta](https://github.com/dandavison/delta) | `c0e9beb59305b739` | MIT |
| [duf](https://github.com/muesli/duf) | `137001351adaa63a` | MIT |
| [dust](https://github.com/bootandy/dust) | `4c9c6183d8fb405c` | Apache-2.0 |
| [eza](https://github.com/eza-community/eza) | `aed4c5853a286846` | EUPL-1.2 |
| [fd](https://github.com/sharkdp/fd) | `1b998e95b8fb679f` | MIT, Apache-2.0 |
| [fzf](https://github.com/junegunn/fzf) | `1095557a697a522a` | MIT |
| [Git reference manual](https://git-scm.com/docs) | `29a03b0ba2b0ed69` | GPL-2.0-only |
| [GNU Bash manual](https://www.gnu.org/software/bash/manual/) | `b24f2dbb9d888e27` | GFDL-1.3-no-invariants-or-later |
| [GNU Coreutils manual](https://www.gnu.org/software/coreutils/manual/) | `5fcf61afb6b336b9` | GFDL-1.3-no-invariants-or-later |
| [GNU Diffutils manual](https://www.gnu.org/software/diffutils/manual/) | `062c5254a1f6a0c5` | GFDL-1.3-no-invariants-or-later |
| [GNU findutils manual](https://www.gnu.org/software/findutils/manual/find.html) | `95006c1c8e56e8ac` | GFDL-1.3-no-invariants-or-later |
| [GNU grep manual](https://www.gnu.org/software/grep/manual/) | `96b00026b5d224fd` | GFDL-1.3-no-invariants-or-later |
| [GNU sed manual](https://www.gnu.org/software/sed/manual/) | `6f5694b2556b9b45` | GFDL-1.3-no-invariants-or-later |
| [gping](https://github.com/orf/gping) | `2b368f6cc6199a66` | MIT |
| [hyperfine](https://github.com/sharkdp/hyperfine) | `8453006a26292241` | MIT, Apache-2.0 |
| [iostat(1), Ubuntu 24.04 manual page](https://manpages.ubuntu.com/manpages/noble/man1/iostat.1.html) | `d7ddeb9998e40525` | GPL-2.0-or-later |
| [jq manual](https://jqlang.org/manual/) | `40610646b614d8d6` | CC-BY-3.0 |
| [Jujutsu (jj)](https://github.com/jj-vcs/jj) | `d3e08a7505856df3` | Apache-2.0 |
| [kill(1), Ubuntu 24.04 manual page](https://manpages.ubuntu.com/manpages/noble/man1/kill.1.html) | `4de31f990f4be327` | LGPL-2.1-or-later |
| [less(1), Ubuntu 24.04 manual page](https://manpages.ubuntu.com/manpages/noble/man1/less.1.html) | `472fbb15a665bcfc` | GPL-3.0-or-later |
| [mawk(1), Ubuntu 24.04 manual page](https://manpages.ubuntu.com/manpages/noble/man1/mawk.1.html) | `8738f99abe2e68cb` | GPL-2.0-only |
| [ping(8), Ubuntu 24.04 manual page](https://manpages.ubuntu.com/manpages/noble/man8/ping.8.html) | `e03dc24f71cd5825` | BSD-3-Clause |
| [procs](https://github.com/dalance/procs) | `88c4d3aa0d62e881` | MIT |
| [ps(1), Ubuntu 24.04 manual page](https://manpages.ubuntu.com/manpages/noble/man1/ps.1.html) | `4f61d74acb5a7b68` | LGPL-2.1-or-later |
| [ripgrep user guide](https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md) | `2dd384575394f4b1` | Unlicense, MIT |
| [scp(1), Ubuntu 24.04 manual page](https://manpages.ubuntu.com/manpages/noble/man1/scp.1.html) | `8925b62002c66cbf` | SSH-OpenSSH |
| [sd](https://github.com/chmln/sd) | `d917c9834bea2bed` | MIT |
| [Signal (IPC) (Wikipedia)](https://en.wikipedia.org/wiki/Signal_(IPC)) | `ce8edcfa2458c888` | CC-BY-SA-4.0 |
| [ssh(1), Ubuntu 24.04 manual page](https://manpages.ubuntu.com/manpages/noble/man1/ssh.1.html) | `7875e4c6a7743127` | SSH-OpenSSH |
| [ssh-keygen(1), Ubuntu 24.04 manual page](https://manpages.ubuntu.com/manpages/noble/man1/ssh-keygen.1.html) | `dc3b74a1467cedb1` | SSH-OpenSSH |
| [tar(1), Ubuntu 24.04 manual page](https://manpages.ubuntu.com/manpages/noble/man1/tar.1.html) | `e3baeb3cde5e4420` | GPL-3.0-or-later |
| [tldr-pages](https://github.com/tldr-pages/tldr) | `28aedb413b85f86f` | CC-BY-4.0 |
| [top(1), Ubuntu 24.04 manual page](https://manpages.ubuntu.com/manpages/noble/man1/top.1.html) | `64d1c3104a67edc8` | LGPL-2.1-or-later |
| [tree(1), Ubuntu 24.04 manual page](https://manpages.ubuntu.com/manpages/noble/man1/tree.1.html) | `9847b24a1da661bb` | GPL-2.0-or-later |
| [xh](https://github.com/ducaale/xh) | `2e7ca995f972a659` | MIT |
| [yq documentation](https://mikefarah.gitbook.io/yq/) | `f1aadf3f99260746` | MIT |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | `b96090a5ddb86b38` | MIT |
