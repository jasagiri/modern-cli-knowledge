# Spec table: http

One row per claim of the sections "Differences that change results" (D) and "When to keep the classic command" (K) of `skills/modern-cli/details/http.md`. 例 = an example of the page names the ID in a `# spec:` line; 本文のみ = no example does, for the category and reason given (MCLI-SPEC-02).

| ID | 箇所 | 主張 | 確かめ |
|---|---|---|---|
| CLI-XH-01 | D1 | When standard input is not a terminal xh reads it as the body: a plain GET becomes a POST and `key=value` items are refused; `--ignore-stdin` avoids it | 例 |
| CLI-XH-02 | D2 | `key=value` builds JSON and sets `Content-Type: application/json` and `Accept`, where `curl -d` sends a form; `-f` sends a form | 例 |
| CLI-XH-03 | D3 | `n=1` is the string `"1"` and `n:=1` is the number 1 | 例 |
| CLI-XH-04 | D4 | The method is POST as soon as there is a body and GET otherwise unless written first | 例 |
| CLI-XH-05 | D5 | Query values are percent-encoded: `b==c%d` is sent as `b=c%25d` | 例 |
| CLI-XH-06 | D6 | `@file` sends the file as is, with the content type of its kind (JSON here, `application/octet-stream` for `blob.bin`) | 例 |
| CLI-XH-07 | D7 | xh formats and colours the response on a terminal, prints the request only with `-v`/`--print`, and prints the body unformatted when piped | 本文のみ (通信: the response and a terminal are not available to an offline example) |
| CLI-XH-08 | D8 | xh exits with an error status when the server replies with an error (`--check-status`), where `curl` exits 0 unless `-f` | 本文のみ (通信: needs a server reply, and `--offline` sends nothing) |
| CLI-XH-09 | D9 | Neither follows redirects by default: `curl -L`, `xh --follow` | 本文のみ (通信: needs a server that redirects) |
| CLI-XH-10 | D10 | The headers print in an order the examples do not rely on | 本文のみ (助言: advice about ordering, nothing to assert; the examples pick lines with grep) |
| CLI-XH-11 | D11 | With no scheme xh uses `http://`; write `https://` for TLS | 例 |
| CLI-XH-12 | D12 | The examples were checked with xh 0.26.3 | 本文のみ (版: the version is checked by MCLI-VER-01 in docs/tool-versions.md, not by an example) |
| CLI-XH-13 | K1 | Keep `curl` in POSIX scripts, CI images and servers without xh | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-XH-14 | K2 | Keep `curl` for uploads, resumable downloads, proxies, client certificates and protocols other than HTTP | 本文のみ (助言: advice on when to choose, not a result) |
| CLI-XH-15 | K3 | Keep `curl` when the exact bytes of the request must be controlled | 本文のみ (助言: advice on when to choose, not a result) |
